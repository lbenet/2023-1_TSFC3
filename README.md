# Temas Selectos de Física Computacional III

## Aritmética de intervalos

### Grupo 8380, 2023-1

Luis Benet
[Instituto de Ciencias Físicas, UNAM](https://www.fis.unam.mx)

Julián Ramírez Castro
[Facultad de Ciencias, UNAM](http://www.fciencias.unam.mx)

Lunes: 11-14


---

## Temario

0. `git` y programación en `Julia`
1. Aritmética de punto flotante y redondeo
1. Aritmética de intervalos
1. Funciones de intervalos
1. Raíces de funciones: Métodos rigurosos de bisección y Newton
1. Cuadratura numérica
1. Mínimos y máximos de funciones: Optimización local y global
1. Diferenciación automática

<!-- Extras:

1. Propagación de constricciones
1. Aproximación de funciones mediante series de Taylor; cálculo del error
1. Diferenciación automática en varias variable
1. Ecuaciones diferenciales ordinarias y el método de integración de Taylor -->

### Bibliografía

- R.E. Moore, R. Baker Kearfott & M.J. Cloud, Introduction to Interval Analysis, SIAM, 2009
- W. Tucker, Validated Numerics: A Short Introduction to Rigorous Computations, Princeton University Press, 2011

---

### Algunas ligas útiles

- **git**
	- [Git Guides](https://github.com/git-guides/install-git)

	- [Learn Git branching](https://learngitbranching.js.org/)

	- [Become a Git guru](https://www.atlassian.com/git/tutorials/)

	- [Github get started](https://docs.github.com/en/github/getting-started-with-github)

- **Julia**
	- [Julia Documentation](https://docs.julialang.org/en/v1/)

	- [Julia programming for nervous beginners](https://www.youtube.com/watch?v=ub3tqCWZmo4&list=PLP8iPy9hna6Qpx0MgGyElJ5qFlaIXYf1R)


- **Markdown**
	- [Markdown guide](https://www.markdownguide.org/getting-started/)

---

### Preparación (set-up)

1. Instalar `git`:
    Seguir las instrucciones descritas en [aquí](https://www.atlassian.com/git/tutorials/install-git), que dependen de la plataforma que usan:  [Linux](https://www.atlassian.com/git/tutorials/install-git#linux), [Mac](https://www.atlassian.com/git/tutorials/install-git#mac-os-x),  [Windows](https://www.atlassian.com/git/tutorials/install-git#windows)

2. Instalar Julia:
    Ir a https://julialang.org/downloads/, descargar [la última versión estable](https://julialang.org/downloads/#current_stable_release) (actualmente es la v1.8.0) y  que sea adecuada a su plataforma.

3. Verificar el funcionamiento de Julia; ver las notas específicas para [cada plataforma](https://julialang.org/downloads/platform/):
    Abran la aplicación que acaban de instalar y corran el comando: `1+1`.

4. Instalar el [Jupyter Lab](https://jupyter.org/) (o el Jupyter Notebook) siguiendo [las instrucciones oficiales](https://jupyter.org/install).
