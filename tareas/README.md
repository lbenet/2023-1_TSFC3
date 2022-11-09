# Tareas

En este subdirectorio encontrarán los archivos donde se enuncian las tareas, que igual que las notas del curso, están en formato `.jl` y pueden ser convertidas a Jupyter notebooks (formato `.ipynb`) usando ['Literate.jl'](https://github.com/fredrikekre/Literate.jl), aunque esto no es esencial para hacer las tareas.

Las tareas deberán ser enviadas como *pull requests* (PR), que deberán ser aceptados **antes** de la fecha que se indica en la tabla abajo. Una condición importante para que su tarea sea aceptada es que pase los tests a partir del código que han escrito. Otra condición importante es que el código esté adecuadamente documentado, o al menos, con comentarios que expliquen con claridad qué se hace.

Cada tarea incluye indicaciones precisas de qué archivos deben subir en el PR, que en general está en formato `.jl`, qué modificaciones tienen que hacer (en otros archivos) para que los tests corran correctamente de forma automática, y dónde deben estar colocados los archivos que envíen (en qué directorio). Los tests se corren de manera automática cuando ustedes abren el PR, o al subir a GitHub nuevos commits, pero también pueden ser corridos localmente en su computadora, como se indica abajo.

Típicamente, deberán subir su código en un archivo que estará en `Intervalos/src/sub_dir/`, donde `sub_dir` es el subdirectorio en que cada equipo **por separado** trabajará. Además, deberán modificar *apropiadamente* el archivo `Intervalos/src/Intervalos.jl` para que sea su código el que se ejecute en los tests.

Para hacer pruebas (locales) de lo que van trabajando, pueden correr los tests usando el comando
```bash
julia --project=Intervalos -e 'import Pkg; Pkg.test()'
```
o también
```bash
julia --project=Intervalos Intervalos/test/runtests.jl
```
desde el directorio *raíz* del curso. En ambos casos, el archivo `Intervalos/test/runtests.jl` se corre y carga el módulo `Intervalos`. El módulo `Intervalos` se carga usando el comando `using Intervalos`, que es reconocido gracias a que usamos `julia --project=Intervalos` que usa el proyecto `Intervalos/Project.toml`. Indirectamente, se carga el código `Intervalos/src/Intervalos.jl`, que es desde donde se llamará al código de su tarea. Los tests se llevan a cabo usando julia v1.6 y v1.8.

## Fechas de entrega

|                   | Aceptación del PR  |         Estado         |
|:------------------|:------------------:|:----------------------:|
|        Tarea 1    |  11/11/2023        | Abierta    |
|        Tarea 2    |  28/11/2023        | Abierta    |
| | |