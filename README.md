# pong-assembly
To run pong-assembly, you need to have QEMU and gcc. installed.

To try pong-assembly, clone the project and include the submodules.

```sh
$ git clone --recursive-submodules https://github.com/EndPositive/pong-assembly.git
```

Then run the following command to compile and boot pong-assembly.

```sh
$ make test
```


Pong-assembly is written in Assembly x86 AT&T and uses a library called "bootlib", made by [Maarten de Vries](https://github.com/de-vri-es/) and [Maurice Bos](https://github.com/m-ou-se/).