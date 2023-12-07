#!/usr/bin/python3
from typing import Literal
from ansible.plugins.action import ActionBase
from ansible.utils.display import Display
from ansible.errors import AnsibleError
from ansible import constants as C
import tempfile
import requests
import re
import os

display = Display()


class ActionModule(ActionBase):
    TRANSFERS_FILES = True

    def download_blocklist(self, url: str) -> str:
        display.v(f"Downloading blocklist {url}")
        response = requests.get(url)
        if not response.ok:
            raise AnsibleError(
                f"Could not download blocklist {url}. Status code {response.status_code}: {response.text}"
            )
        return response.text

    def convert_to_rpz(
        self,
        rpz_zone: str,
        blocklist: str,
        block_action: Literal["NXDOMAIN", "NODATA", "BLACKHOLE"],
    ) -> str:
        """
        Syntax Details:
        https://datatracker.ietf.org/doc/html/draft-vixie-dnsop-dns-rpz-00
        """
        HOST_REGEX = re.compile(r"0.0.0.0 ([a-z\d\.-]+)( .*)?")
        result = f"$ORIGIN {rpz_zone}\n"
        result += "$TTL 3600\n"
        result += "@ IN SOA ns.vpn.private. admin.ftsell.de 1 7200 3600 1209600 3600\n"
        result += "@ IN NS ns.vpn.private.\n"
        for line in blocklist.splitlines():
            match = HOST_REGEX.fullmatch(line)

            # keep comments
            if line.startswith("#"):
                result += f";{line.lstrip('#')}\n"

            # keep empty lines
            elif line == "":
                result += "\n"

            # skip non-block instruction entries
            elif not line.startswith("0.0.0.0") or line.endswith("0.0.0.0"):
                continue

            # skip hosts that bind does not support
            elif "_" in line:
                continue

            # convert host entries to rpz policies
            elif match is not None:
                name = match.group(1)

                if block_action == "NXDOMAIN":
                    result += f"{name} IN CNAME .\n"
                elif block_action == "NODATA":
                    result += f"{name} IN CNAME .*\n"
                elif block_action == "BLACKHOLE":
                    result += f"{name} IN A 0.0.0.0\n"
                    result += f"{name} IN AAAA ::\n"

            else:
                raise AnsibleError(f"host entry '{line}' could not be handled")

        return result

    def create_content_tempfile(self, content: str) -> tempfile.TemporaryFile:
        """Create a tempfile containing defined content"""
        fd, content_tempfile = tempfile.mkstemp(dir=C.DEFAULT_LOCAL_TMP, prefix=".")
        f = os.fdopen(fd, "wb")
        try:
            f.write(content.encode())
        except Exception as err:
            os.remove(content_tempfile)
            raise Exception(err)
        finally:
            f.close()
        return content_tempfile

    def run(self, tmp=None, task_vars=None):
        super(ActionModule, self).run(tmp, task_vars)

        # assign local vars for easier use
        rpz_zone = self._task.args.get("rpz_zone")
        sources = self._task.args.get("sources", [])
        block_action = self._task.args.get("block_action", "NXDOMAIN")

        # merge all given blocklists
        blocks = "\n".join((self.download_blocklist(url) for url in sources))
        rpz = self.convert_to_rpz(rpz_zone, blocks, block_action)

        # deploy blocklists on the host
        display.v("Uploading merged blocklist")
        tmpfile = self.create_content_tempfile(rpz)
        remote_tmp = self._connection._shell.join_path(self._connection._shell.tmpdir, ".source.rpz")
        self._transfer_file(tmpfile, remote_tmp)
        self._loader.cleanup_tmp_file(tmpfile)
        return self._execute_module(
            module_name="ansible.builtin.copy",
            module_args=dict(
                src=remote_tmp,
                dest=self._task.args.get("dest"),
                owner=self._task.args.get("owner"),
                group=self._task.args.get("group"),
                mode=self._task.args.get("mode"),
            ),
        )
