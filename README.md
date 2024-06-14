# finnfrastructure

My personal infrastructure *configuration-as-code* repository.
Its goal is to contain all necessary configuration for my different servers to allow easier setup.

### How to generate an Installer ISO

Run the following command.
The resulting ISO file is then located in the printed path + `/iso`.

```shell
nix build --print-out-paths '.#installer.x86_64-linux'
```
