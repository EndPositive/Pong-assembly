# Pong-assembly
Pong-assembly is written in Assembly x86 AT&T. This project includes a menu screen, the actual game, and saves highscores. The game includes a wall moving closer as you get more points.

![Start menu](https://user-images.githubusercontent.com/25148195/72667769-ae3f4280-3a1f-11ea-8012-962675281752.png)
![Game](https://user-images.githubusercontent.com/25148195/72667765-ae3f4280-3a1f-11ea-982a-a06c8d76ad58.png)
![Game over](https://user-images.githubusercontent.com/25148195/72667766-ae3f4280-3a1f-11ea-8be0-3808b6678a22.png)
![Highscore](https://user-images.githubusercontent.com/25148195/72667767-ae3f4280-3a1f-11ea-97e1-3e0880e06b96.png)


To run pong-assembly, you need to have QEMU and gcc installed.

To try pong-assembly, clone the project and include the submodules.

```sh
$ git clone --recursive https://github.com/EndPositive/pong-assembly.git
```

Then run the following command to compile and boot pong-assembly.

```sh
$ make test
```

Pong-assembly is written in Assembly x86 AT&T and uses a library called "bootlib", made by [Maarten de Vries](https://github.com/de-vri-es/) and [Maurice Bos](https://github.com/m-ou-se/).
