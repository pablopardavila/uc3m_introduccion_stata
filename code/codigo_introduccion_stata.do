*********************************
***** INTRODUCCIÓN A STATA ******
*********************************

* pablo.pardavila@uc3m.es
* Este es un archivo .do

* Si escribes un * antes de tu frase, STATA
* lo leerá como una nota. Puedes hacer tus anotaciones así.

* Si no escribes el asterisco (*), entonces STATA lo leerá como un comando:

import excel "attacks1.xlsx", sheet("Sheet1") firstrow

*******************************************************************************
*** NOTA: aquí debes escribir la ruta completa a tu archivo. O simplemente  ***
***       hazlo desde la barra de herramientas: Archivo>Importar>Excel>      ***
***       Explorar>[X] Importar primera fila como nombres de variable.       ***
*******************************************************************************

* Ahora que hemos importado el dataset, hagamos un histograma. Puedes ejecutar una sola línea de código desde un archivo .do colocando el cursor en la línea que quieres ejecutar y usando el comando Ctrl+D en Windows o Cmd+D en Mac.

histogram nkill, bin(5) frequency


* Para saber cuántos registros cumplen una condición podemos usar `list'.
* Por ejemplo, ¿cuántos países tuvieron más de 300 víctimas?

 list country if nkill>300
 
* Sin embargo, con eso solo obtenemos el nombre del país. ¿Y si también queremos saber en qué año esos países tuvieron más de 300 víctimas?
 
 list country year if nkill>300
 
* Si necesitas ayuda para conocer la sintaxis de un comando, escribe `help comando'. Por ejemplo:
help drop

* Intentemos usar el comando drop
drop

* No funcionará porque necesita, al menos, el nombre de una variable
drop country

* Ahora hemos eliminado la variable `country' de nuestro dataset
* Podríamos añadir una condición para eliminar solo ciertas observaciones. Si quisiéramos eliminar únicamente aquellas con más de 300 víctimas, añadiríamos una condición:
	
	* `drop if nkill>300'


* Hasta ahora hemos estado explorando qué puede hacer STATA: gráficos, tablas, listas... pero empecemos desde el principio.
* Cuando nos enfrentamos a un nuevo dataset, lo primero que debemos hacer es revisar su estructura: los nombres de las variables, si son letras (también llamadas strings o caracteres) o números, cuál es su media, los valores máximos y mínimos... para eso:

codebook attacks1

* Esto nos dará mucha información sobre todas nuestras variables. Hacer esto con un dataset grande puede ser demasiado...

* Hay otras formas de conocer el tipo de variable. 1) Desde el visor/editor de datos (si la variable es azul, es numérica; si es roja, es string); 2) Con el comando describe


* tabulate (o tab) nos dará frecuencia, porcentaje y frecuencia acumulada

tab nkill

* summarize (o sum) nos dará observaciones, media, desviación estándar, valor máximo y mínimo

sum nkill

*******************************************************************************
***                                                                         ***
*** NOTA: a veces las variables numéricas pueden estar almacenadas como     ***
*** caracteres. Por eso es bueno revisar siempre el tipo de nuestras        ***
*** variables.                                                              ***
***                                                                         ***
*******************************************************************************

* Trabajemos ahora con STATA como si fuera un proyecto real. Para eso limpiemos nuestro entorno con el comando `clear' e importemos un nuevo dataset (algo más complejo): attacks2

clear
import excel "attacks2.xlsx", sheet("Sheet1") firstrow

* Para ver su estructura
describe
sum

* Podemos usar sum con más de una variable
sum gdp type

* Para ver la frecuencia de una variable:
tab type


*       type |      Freq.     Percent        Cum.
*------------+-----------------------------------
*   accident |          6       20.00       20.00
*       bomb |         10       33.33       53.33
*      knife |         10       33.33       86.67
*     poison |          4       13.33      100.00
*------------+-----------------------------------
*      Total |         30      100.00

* Ahora sabemos que los tipos de ataque más frecuentes en nuestro dataset son las bombas (10) y los ataques con cuchillo (10). Después los accidentes (6) y, en último lugar, el veneno (4).


* Aprendamos a generar una nueva variable. Normalmente preferimos trabajar con el PIB per cápita en lugar del PIB absoluto. Para crear una nueva variable usamos `generate':

generate gdp_pc = gdp / population

* Podemos hacer cambios a una variable existente con `replace'. Cambiemos la variable `gdp_pc' para hacerla más grande e interpretable.
replace gdp_pc = gdp_pc * 1000

* Fíjate en la ventana de variables. Verás que la nueva variable `gdp_pc' aparece, pero no tiene etiqueta. Las etiquetas son útiles para identificar variables. A veces trabajaremos con muchísimas variables y es fácil olvidar cuál es cuál. Piensa que en algunos datasets las variables pueden estar codificadas como cosas como `eg2_lxr'... ¿qué es eso??? Por eso las etiquetas son útiles.

label variable gdp_pc "GDP per capita"


*******************************
**  EXTRA: ETIQUETAS A VALORES  **
*******************************

* También podemos añadir etiquetas a los valores de una variable. A veces variables como `gender' estarán codificadas como 0 y 1. Añadir etiquetas a los valores 0 y 1 puede aclarar las cosas. El proceso aquí es algo diferente. Primero debes CREAR la etiqueta, luego ASIGNARLA a cada valor y finalmente VINCULAR los valores etiquetados a la variable. Imagínalo literalmente como si estuvieras creando etiquetas y luego pegándolas a las cosas (los valores).

* Hagámoslo con nuestra variable `democracy'. Tiene valores del 1 al 10. Primero creamos etiquetas. Por ejemplo, podemos etiquetar los países del 1 al 5 como dictaduras y los países del 6 al 10 como democracias (sé que esto está muy mal en Ciencias Políticas, pero que sea nuestro ejemplo tonto).

	* CREAR las etiquetas
		label define democracy_label 1 "Dictatorship" 2 "Dictatorship" 3 "Dictatorship" 4 "Dictatorship" 5 "Dictatorship" 6 "Democracy" 7 "Democracy" 8 "Democracy" 9 "Democracy" 10 "Democracy"

	* VINCULAR las etiquetas a los valores
		label values democracy democracy_label
		
			** Si se ha hecho correctamente, puedes entrar al Visor de Datos
			** y revisar el cuadro de variables. Verás que `democracy' tiene
			** etiquetas de valores asociadas.
	
*******************************
*******************************
*******************************


	
* ¿Recuerdas que `tab' se usaba para tablas de frecuencia? Pues también podemos hacer tablas cruzadas de frecuencia entre variables. Mira:

tab type gdp
tab type democracy
tab type population

* ¡Son todas iguales! Transmiten la misma información. Por lo tanto, son colineales.
tab gdp democracy
tab gdp population
tab democracy population

* No nos están dando más información porque esencialmente son lo mismo. Por esa razón, si quisiéramos explicar la variación en una variable, usar las tres sería inútil. Si ejecutamos una regresión con al menos dos de esas variables, STATA omitirá una de ellas por colinealidad. Como ejemplo, intentemos explicar el número de víctimas (esa es nuestra Y, nuestra variable dependiente):

regress nkill gdp democracy mountains

* ¿Ves? Democracy ha sido omitida por colinealidad.


* Para ejecutar una MCO primero necesitaríamos hacer un correlograma:
pwcorr gdp population mountains democracy nkill temperature, sig

* Nada muestra una correlación muy alta o significativa con nkill. Nuestro dataset es un dataset simulado, por eso. Sin embargo, digamos que la democracia explica bien el número de víctimas. El siguiente paso es representar esa correlación:

scatter nkill democracy

* Podemos hacerlo más elaborado
twoway(scatter nkill democracy) (lfit nkill democracy)

* Ahora podemos ejecutar una regresión
regress nkill mountains democracy temperature


*      Source |       SS           df       MS      Number of obs   =        30
*-------------+----------------------------------   F(3, 26)        =     16.11
*       Model |  677.386218         3  225.795406   Prob > F        =    0.0000
*    Residual |  364.480449        26  14.0184788   R-squared       =    0.6502
*-------------+----------------------------------   Adj R-squared   =    0.6098
*       Total |  1041.86667        29  35.9264368   Root MSE        =    3.7441

*------------------------------------------------------------------------------
*       nkill | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
*-------------+----------------------------------------------------------------
*   mountains |   .3260621   .0658284     4.95   0.000     .1907498    .4613744
*   democracy |   9.393341    2.42215     3.88   0.001      4.41454    14.37214
* temperature |  -2.372822   .3827984    -6.20   0.000    -3.159676   -1.585969
*       _cons |  -254.9601   59.03223    -4.32   0.000    -376.3025   -133.6176
*------------------------------------------------------------------------------

* La interpretación de los coeficientes:
	* Por cada aumento de 1 unidad en el número de `mountains', las muertes
	* esperadas aumentan en aproximadamente 0.33, ceteris paribus.
	
	* Por cada aumento de 1 unidad en `democracy', las muertes esperadas
	* aumentan en aproximadamente 9.4, ceteris paribus.
	
	* Por cada aumento de 1 unidad en `temperature', las muertes esperadas
	* disminuyen en 2.37, ceteris paribus.
	

* Nuestro modelo explica aproximadamente el 65% de la variación en las muertes. Manteniendo constantes los demás factores, más montañas y puntuaciones más altas de democracia se asocian con más muertes, mientras que temperaturas más altas se asocian con menos muertes. Todos los predictores son estadísticamente significativos al 1%. Fíjate en que, a primera vista, la democracia parecía relacionarse negativamente con las muertes. ¡Pero una vez que controlamos por geografía (montañas) y clima (temperatura), la relación se invirtió! Esto significa que la democracia está positivamente relacionada con las muertes una vez que se tienen en cuenta esos factores de confusión.


* VISUALIZACIÓN DE DATOS

* Gráfico de barras de muertes medias por tipo de evento
graph bar nkill, over(type) title("Average Deaths by Event Type")
graph bar nkill, over(country) title("Average Deaths by Event Type")