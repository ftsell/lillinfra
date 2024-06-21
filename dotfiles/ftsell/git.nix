# Configuration for Home-Managers programs.git options
{
  enable = true;
  diff-so-fancy.enable = true;
  diff-so-fancy.rulerWidth = 110;
  ignores = [
    "**/.*.swp"
    "**/__pycache__"
    ".idea"
  ];
  aliases = {
    # git auf deutsch
    eroeffne = "init";
    machnach = "clone";
    zieh = "pull";
    fueghinzu = "add";
    drueck = "push";
    pfusch = "push";
    zweig = "branch";
    verzweige = "branch";
    uebergib = "commit";
    erde = "rebase";
    unterscheide = "diff";
    vereinige = "merge";
    bunkere = "stash";
    markiere = "tag";
    nimm = "checkout";
    tagebuch = "log";
    zustand = "status";
  };
  extraConfig = {
    user = {
      name = "ftsell";
      email = "dev@ftsell.de";
    };
    core = {
      autocrlf = "input";
      fscache = true;
    };
    pull = {
      rebase = true;
    };
    color = {
      ui = "auto";
    };
    init = {
      defaultBranch = true;
    };
    push = {
      autoSetupRemote = true;
    };
  };
  includes =
    let
      workConfig = {
        user = {
          name = "ftsell";
          email = "f.sell@vivaconagua.org";
        };
      };
      cccConfig = {
        user = {
          name = "finn";
          email = "ccc@ftsell.de";
        };
      };
    in
    [
      {
        condition = "hasconfig:remote.origin.url:git@github.com/viva-con-agua/**";
        contents = workConfig;
      }
      {
        condition = "hasconfig:remote.origin.url:https://github.com/viva-con-agua/**";
        contents = workConfig;
      }
      {
        condition = "hasconfig:remote.origin.url:forgejo@git.hamburg.ccc.de:*/**";
        contents = cccConfig;
      }
      {
        condition = "hasconfig:remote.origin.url:https://git.hamburg.ccc.de/**";
        contents = cccConfig;
      }
    ];
}
