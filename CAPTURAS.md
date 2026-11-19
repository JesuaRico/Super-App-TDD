# Guía de capturas (qué sacar, cómo nombrarlas y con qué comandos)

> Las capturas de ROJO se obtienen rompiendo a propósito una línea con `tool/sabotaje.dart`. Las pruebas fallan de verdad, pero el fallo es provocado: confirma con tu profe que esto le parece bien como evidencia.

## Antes de empezar

- Abre la terminal en la carpeta raíz del proyecto (donde está `pubspec.yaml`), por ejemplo la terminal de VS Code.
- Agranda la letra para que se lea. Cada captura debe mostrar **el comando que escribiste y el resultado completo**.
- Capturas: Windows `Win + Shift + S` · Mac `Cmd + Shift + 4`. Guárdalas en una carpeta `capturas/` con los nombres exactos de abajo.
- Antes de cada ronda corre `dart tool/sabotaje.dart estado`: todo debe decir *verde*.

## Opción completa: 2 capturas por ronda (22) + extras

Repite este bloque para cada ronda N (los comandos exactos están en la tabla de abajo):

```bash
dart tool/sabotaje.dart rojo N
flutter test <archivo> --name "<filtro>" -r expanded      # CAPTURA  RNN_nombre_ROJO.png
dart tool/sabotaje.dart verde N
flutter test <archivo> --name "<filtro>" -r expanded      # CAPTURA  RNN_nombre_VERDE.png
```

| Ronda | Tema | Qué se rompe en el ROJO | Archivo de prueba | Filtro (`--name`) | ROJO: debe mostrar | VERDE: debe mostrar |
|---|---|---|---|---|---|---|
| R02 | Dinero y fechas | porcentaje() deja de redondear al más cercano | `test/dominio_test.dart` | `dinero y fechas` | `Some tests failed` y 1 prueba(s) con ✗/[E] | `+4: All tests passed!` |
| R03 | Monedero | el monedero no valida el saldo | `test/dominio_test.dart` | `Monedero` | `Some tests failed` y 2 prueba(s) con ✗/[E] | `+10: All tests passed!` |
| R04 | Bus de eventos | un suscriptor que falla tumba a los demás | `test/dominio_test.dart` | `Bus de eventos` | `Some tests failed` y 1 prueba(s) con ✗/[E] | `+4: All tests passed!` |
| R05 | Mensajería | límite de caracteres 100 veces mayor | `test/dominio_test.dart` | `Mensajería` | `Some tests failed` y 1 prueba(s) con ✗/[E] | `+6: All tests passed!` |
| R06 | Comercio | comisión de 5% pasa a 0% | `test/servicios_test.dart` | `Comercio` | `Some tests failed` y 1 prueba(s) con ✗/[E] | `+7: All tests passed!` |
| R07 | Transporte | tope de tarifa dinámica de 2.0x a 10.0x | `test/servicios_test.dart` | `Transporte` | `Some tests failed` y 1 prueba(s) con ✗/[E] | `+13: All tests passed!` |
| R08 | Mini-apps y permisos | se apaga la verificación de permisos | `test/dominio_test.dart` | `Mini-apps` | `Some tests failed` y 2 prueba(s) con ✗/[E] | `+6: All tests passed!` |
| R09 | Lealtad | puntos por gasto con $1 en vez de $10 | `test/retencion_test.dart` | `Lealtad` | `Some tests failed` y 7 prueba(s) con ✗/[E] | `+16: All tests passed!` |
| R10 | Analítica | WAU mira 3 días en vez de 7 | `test/retencion_test.dart` | `Analítica` | `Some tests failed` y 1 prueba(s) con ✗/[E] | `+7: All tests passed!` |
| R11 | Notificaciones y sugerencias | tope de promociones 2 → 20 y horario de sugerencias | `test/retencion_test.dart` | `Notificaciones éticas|Sugerencias` | `Some tests failed` y 2 prueba(s) con ✗/[E] | `+8: All tests passed!` |
| R12 | ViewModels | el chat no muestra el error al fallar un envío | `test/vms_test.dart` | `ViewModel` | `Some tests failed` y 1 prueba(s) con ✗/[E] | `+22: All tests passed!` |

Nombres de archivo, en orden:

- `R02_dinero_ROJO.png`  y  `R02_dinero_VERDE.png`
- `R03_monedero_ROJO.png`  y  `R03_monedero_VERDE.png`
- `R04_eventos_ROJO.png`  y  `R04_eventos_VERDE.png`
- `R05_mensajeria_ROJO.png`  y  `R05_mensajeria_VERDE.png`
- `R06_comercio_ROJO.png`  y  `R06_comercio_VERDE.png`
- `R07_transporte_ROJO.png`  y  `R07_transporte_VERDE.png`
- `R08_miniapps_ROJO.png`  y  `R08_miniapps_VERDE.png`
- `R09_lealtad_ROJO.png`  y  `R09_lealtad_VERDE.png`
- `R10_analitica_ROJO.png`  y  `R10_analitica_VERDE.png`
- `R11_notificaciones_ROJO.png`  y  `R11_notificaciones_VERDE.png`
- `R12_viewmodels_ROJO.png`  y  `R12_viewmodels_VERDE.png`

**Extras recomendados:**

- `00_estructura_proyecto.png` — el árbol de carpetas (`lib/`, `test/`, `tool/`) en VS Code.
- `13_VERDE_total_104_pruebas.png` — con todo restaurado (`dart tool/sabotaje.dart verde`), corre `flutter test -r expanded`; debe decir `+104: All tests passed!`.
- `14_app_inicio.png`, `15_app_chat_dinero.png`, `16_app_tienda.png`, `17_app_viajes.png`, `18_app_metricas.png` — la app corriendo con `flutter run -d chrome`.
- `19_app_killswitch.png` — en Inicio, pulsa *Simular falla: apagar Viajes* y captura que desaparece de la barra.

## Opción mínima: 2 capturas

```bash
dart tool/sabotaje.dart rojo todas
flutter test -r expanded         # CAPTURA  01_ROJO_total.png   (28 fallan, 76 pasan)
dart tool/sabotaje.dart verde
flutter test -r expanded         # CAPTURA  02_VERDE_total.png  (+104: All tests passed!)
```

## Si algo sale raro

- `dart tool/sabotaje.dart estado` te dice qué rondas están rotas; `dart tool/sabotaje.dart verde` las restaura todas.
- Nunca edites a mano un archivo que esté en rojo: restaura primero con `verde`.
- Los respaldos viven en la carpeta `.sabotaje/` (se borra sola al volver a verde).
- Si `flutter test` marca un error de **compilación** en `lib/presentacion/pantallas/` o `lib/main.dart`, cópiame el mensaje completo: esos archivos solo pude revisar por sintaxis, no compilarlos con Flutter.
