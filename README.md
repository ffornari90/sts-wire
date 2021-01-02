[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/DODAS-TS/sts-wire)

# STS WIRE 

## Requirements

- fuse installed (Linux and Macos)
  - Linux (Debian or Ubuntu): ` sudo apt install fuse`
    - CentOS or similar: ` sudo dnf install fuse`
  - MacOS: `brew install --cask osxfuse`
    - or use the binary from the [osxfuse website](https://osxfuse.github.io/)
  - Windows:
    - [Use Linux with WSL](https://ubuntu.com/wsl)
    - Other useful program: [winfsp](https://github.com/billziss-gh/winfsp)
  - Further information on fuse dependency with rclone: [rclone mount](https://rclone.org/commands/rclone_mount/)

## Quick start

Download the binary from the latest release on [github](https://github.com/DODAS-TS/sts-wire/releases) and use it from the command line.
### Linux

```bash
wget https://github.com/DODAS-TS/sts-wire/releases/download/v1.0.2/sts-wire_linux
chmod +x sts-wire_linux
mv sts-wire_linux /usr/local/bin
```
### MacOS

```bash
wget https://github.com/DODAS-TS/sts-wire/releases/download/v1.0.2/sts-wire_osx
chmod +x sts-wire_osx
mv sts-wire_osx /usr/local/bin
```

- [Go to How to use](#How-to-use)
- [Go to Launch the program](#Launch-the-program)

### Windows

Download the binary with the browser: [https://github.com/DODAS-TS/sts-wire/releases/download/v1.0.2/sts-wire_windows](https://github.com/DODAS-TS/sts-wire/releases/download/v1.0.2/sts-wire_windows)

**Note:** it is suggested to use the [Windows Terminal](https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701?activetab=pivot:overviewtab)

## Building from source

To compile from the sources you need a [Go](https://golang.org/dl/) version that supports `Go modules` (e.g. `>= v1.12`). You can compile the executable using the `Makefile`:

```bash
# Linux
make build-linux
# Windows
make build-windows
# MacOS
make build-macos
```

## How to use

You can see how to use the program asking for help in the command line:

```bash
# Linux example
./sts-wire_linux -h
```

The result of the above command will be something similar to this:

```text
Usage:
  sts-wire <IAM server> <instance name> <s3 endpoint> <rclone remote path> <local mount point> [flags]
  sts-wire [command]

Available Commands:
  help        Help about any command
  version     Print the version number of Hugo

Flags:
      --config string           config file (default "./config.json")
      --debug                   start the program in debug mode
  -h, --help                    help for sts-wire
      --insecureConn            check the http connection certificate
      --log string              where the log has to write, a file path or stderr (default "/Users/mircotracolli/Library/Application Support/log/sts-wire.log")
      --noPassword              to not encrypt the data with a password
      --refreshTokenRenew int   time span to renew the refresh token in minutes (default 15)

Use "sts-wire [command] --help" for more information about a command.
```

As you can see, to use the `sts-wire` you need the following arguments to be passed:

- `<IAM server>`: the name your IAM server where you can verify your credentials
- `<instance name>`: the name you give to the `sts-wire` instance
- `<s3 endpoint>`: the *s3* server you want to use, also a local one, e.g. `http://localhost:9000`
- `<rclone remote path>`: the remote path that you need to mount locally, relative to the *s3* server, e.g. `/folder/on/my/s3`. It could be any of your buckets, also root `/`.
- `<local mount point>`: the folder where you want to mount the remote source. It could be also relative to the current working folder, e.g. `./my_local_mountpoint`

Alternatively, you can create a YAML configuration file like the following:

```yaml
---
IAM_Server: https://my.iam.server.com
instance_name: test_instance
s3_endpoint: http://localhost:9000
rclone_remote_path: /test
local_mount_point: ./my_local_mountpoint
# Other useful options
IAMAuthURL: http://localhost
IAMAuthURLPort: 3128
log: ./logFile.log
noPassword: false
refreshTokenRenew: 10
insecureConn: false
```
### Launch the program

In the following example you can see how the program is launched:

```bash
# Linux example
./sts-wire_linux https://my.iam.server.com myMinio https://myserver.com:9000 / ./mountedVolume
```

Alternatively, you can use a config file name myConfig.yml with the same values as shown in [how to use section](#How-to-use)

```bash
./sts-wire_linux --config myConfig.yml
```

After that, you have to follow all the instructions and providing a password for credentials encryption when requested.
Eventually, if everything went well, on your browser you will be prompted with a message like:

![mount response](img/response.png)

The volume will stay mounted untill you exit the running *sts-wire* process with `Ctrl+c`
## Contributing

If you want to contribute:

1. create a branch
2. upload your changes
3. create a pull request

Thanks!
