# Environment Variable-based DLL Hijacking

## Background
This repo contains all scripts used to find _Environment Variable-based DLL Hijacking_ candidates on Windows 11 (version 21H2), as described in **[this blog post](https://wietze.github.io/blog/save-the-environment-variables)**. 


## Approach
The first step is to create 'dummy' DLLs for all legitimate DLLs that can be found in trusted locations, such as `c:\windows\system32`.

This project leverages `objdump` and `windres` from `binutils` to get all exports (including ordinals) and resources from a given DLL, respectively. It then uses `x86_64-w64-mingw32-gcc` to compile a DLL that embeds the same resources and implements the same exports, forwarding any calls to the legitimate DLL file in its original location. 

The second step is to find vulnerable programs. To see if an executable is vulnerable, point its relevant environment variables to an attacker-controlled location containing the compiled DLLs, and run it. If the DLL was successfully loaded, a file will be generated in `c:\users\public\`, containing the name of the executable as well as the DLL it loaded. 

## Preparation
The `input/` folder of this repository represents the `C:` root of the target machine. Because the generated DLL files will forward calls to the original/legitimate DLL file, it is important to maintain the folder structure of the original DLL. 

For example, if you want to create a clone of `c:\windows\system32\dbghelp.dll`:
1. Copy a legitimate version of the DLL to `input/windows/system32/dbghelp.dll`;
2. Update `template.c` if necessary;
3. Run the bash script (see Usage section below);
4. Find the compiled DLL file in the `output/` folder.

## Usage
### Docker container
To run this project in a Docker container, do the following:
1. Clone this project and `cd` into the repository's folder;
2. Build the Docker image via 
   ```bash 
   docker build -t wietze/mingw-tools:1.0 .
   ```
3. Run the script via:
   ```bash
   docker run --rm -ti -v `pwd`:/mnt wietze/mingw-tools:1.0 /bin/bash run.sh
   ```

### Natively
To run this project on a Linux-based machine, do the following:
1. Ensure `binutils-mingw-w64-x86-64` is installed, e.g. via:
   ```bash
   apt install binutils-mingw-w64-x86-64 # Debian-based systems only
   ```
2. Verify at least version 38.0 is installed via:
   ```bash
   x86_64-w64-mingw32-objdump -v
   ```
   If an older version is present and cannot be upgraded, you will have to build `binutils-mingw-w64-x86-64` yourself. This can be done by executing:
   ```bash
   bash build.sh
   ```     
3. Clone this project and `cd` into the repository's folder;
4. Run the script via:
   ```bash
   bash run.sh
   ```

## Repos Contents
| Item | Description |
| ---- | ----------- |
| [`run.sh`](/run.sh) | Main project file. For any legitimate files put in the `input/` folder, compiles corresponding dummy DLLs to the `output/` folder. See instructions above. |
| [`template.c`](/template.c) | The C code template that will be used for compiling the target DLLs. |
| [`build.sh`](/build.sh) | File that can be used to build the latest version of `binutils-mingw-w64-x86-64` - optional. |
| [`Dockerfile`](/Dockerfile) | A Dockerfile that when built into a Docker image, can be used for compilation. |
| [`LICENSE`](/LICENSE) | The licence file of this project. |
| `README.md` | This file. |
