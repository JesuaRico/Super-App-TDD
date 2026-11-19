// Herramienta didáctica: simula el estado ROJO de una ronda (rompe una línea a propósito)
// y vuelve al VERDE (restaura el original). Solo usa Dart puro: corre con `dart run`.
//
//   dart tool/sabotaje.dart lista        -> tabla de rondas y comandos de prueba
//   dart tool/sabotaje.dart rojo 3       -> rompe la Ronda 3 (monedero)
//   dart tool/sabotaje.dart rojo todas   -> rompe TODAS las rondas a la vez
//   dart tool/sabotaje.dart verde 3      -> restaura la Ronda 3
//   dart tool/sabotaje.dart verde        -> restaura TODO
//   dart tool/sabotaje.dart estado       -> qué rondas están rotas ahora
import 'dart:io';

class Edicion {
  final String archivo, viejo, nuevo;
  const Edicion(this.archivo, this.viejo, this.nuevo);
}

class Ronda {
  final int n;
  final String titulo, archivoTest, filtro, que;
  final List<Edicion> ediciones;
  const Ronda(this.n, this.titulo, this.archivoTest, this.filtro, this.que,
      this.ediciones);

  String get id => 'R${n.toString().padLeft(2, '0')}';
  String get comando =>
      'flutter test $archivoTest --name "$filtro" -r expanded';
}

const rondas = <Ronda>[
  Ronda(2, "Dinero y fechas", "test/dominio_test.dart", "dinero y fechas",
      "porcentaje() deja de redondear al más cercano", [
    Edicion("lib/dominio/dinero.dart", "(centavos * pct + 50) ~/ 100",
        "(centavos * pct) ~/ 100"),
  ]),
  Ronda(3, "Monedero", "test/dominio_test.dart", "Monedero",
      "el monedero deja de validar el saldo antes de pagar", [
    Edicion("lib/dominio/monedero.dart", "if (saldo(cuenta) < monto)",
        "if (saldo(cuenta) < 0)"),
  ]),
  Ronda(
      4,
      "Bus de eventos",
      "test/dominio_test.dart",
      "Bus de eventos",
      "un suscriptor que falla derrumba a los demás (se quita el aislamiento)",
      [
        Edicion(
            "lib/dominio/eventos.dart",
            "errores.add(err); // se registra y se sigue: aislamiento de fallos",
            "rethrow; // SABOTAJE: ahora un suscriptor que falla derrumba a los demás"),
      ]),
  Ronda(5, "Mensajería", "test/dominio_test.dart", "Mensajería",
      "el límite de caracteres del mensaje se vuelve 100 veces mayor", [
    Edicion("lib/dominio/mensajeria.dart", "t.length > maxCaracteres",
        "t.length > maxCaracteres * 100"),
  ]),
  Ronda(6, "Comercio", "test/servicios_test.dart", "Comercio",
      "la comisión del comercio pasa de 5% a 0%", [
    Edicion("lib/dominio/comercio.dart", "static const int comisionPct = 5;",
        "static const int comisionPct = 0;"),
  ]),
  Ronda(7, "Transporte", "test/servicios_test.dart", "Transporte",
      "el tope de la tarifa dinámica pasa de 2.0x a 10.0x", [
    Edicion(
        "lib/dominio/transporte.dart",
        "static const double maxMultiplicador = 2.0;",
        "static const double maxMultiplicador = 10.0;"),
  ]),
  Ronda(8, "Mini-apps y permisos", "test/dominio_test.dart", "Mini-apps",
      "se desactiva la verificación de permisos de las mini-apps", [
    Edicion("lib/dominio/contexto.dart", "if (!app.permisos.contains(p))",
        "if (false)"),
  ]),
  Ronda(9, "Lealtad", "test/retencion_test.dart", "Lealtad",
      "los puntos por gasto se calculan con \$1 en lugar de \$10 por punto", [
    Edicion(
        "lib/dominio/lealtad.dart",
        "static const int centavosPorPunto = 1000;",
        "static const int centavosPorPunto = 100;"),
  ]),
  Ronda(10, "Analítica", "test/retencion_test.dart", "Analítica",
      "el WAU (usuarios activos semanales) mira 3 días en vez de 7", [
    Edicion("lib/dominio/analitica.dart", "masDias(dia, -6), dia",
        "masDias(dia, -2), dia"),
  ]),
  Ronda(
      11,
      "Notificaciones y sugerencias",
      "test/retencion_test.dart",
      "Notificaciones éticas|Sugerencias",
      "sube el tope de promociones de 2 a 20 por día y cambia el horario de sugerencias",
      [
        Edicion(
            "lib/dominio/notificaciones.dart",
            "static const int maxPromocionalesPorDia = 2;",
            "static const int maxPromocionalesPorDia = 20;"),
        Edicion("lib/dominio/sugerencias.dart", ">= 11 && < 16 =>",
            ">= 11 && < 12 =>"),
      ]),
  Ronda(12, "ViewModels", "test/vms_test.dart", "ViewModel",
      "ChatViewModel deja de mostrar el error cuando falla un envío", [
    Edicion("lib/presentacion/vm/chat_vm.dart", "error = mensajeSeguro(e);",
        "error = null;"),
  ]),
];

const _carpeta = '.sabotaje';

Directory _resp(Ronda r) => Directory('$_carpeta/${r.id}');
bool _enRojo(Ronda r) => _resp(r).existsSync();
String _nombreResp(String archivo) => archivo.replaceAll('/', '__');

Ronda? _buscar(String? txt) {
  final n = int.tryParse((txt ?? '').toLowerCase().replaceAll('r', ''));
  for (final r in rondas) {
    if (r.n == n) return r;
  }
  return null;
}

void _rojo(Ronda r, {bool corto = false}) {
  if (_enRojo(r)) {
    stdout.writeln(
        'La ${r.id} (${r.titulo}) YA está en rojo. Corre: ${r.comando}');
    return;
  }
  // 1) validar que todo se pueda aplicar ANTES de tocar nada
  for (final e in r.ediciones) {
    final f = File(e.archivo);
    if (!f.existsSync() || !f.readAsStringSync().contains(e.viejo)) {
      stderr.writeln('No encuentro el texto esperado en ${e.archivo}.\n'
          'Probablemente ese archivo ya fue modificado. Haz "dart tool/sabotaje.dart verde" '
          'o vuelve a copiar el archivo original.');
      exit(1);
    }
  }
  // 2) respaldar y romper
  _resp(r).createSync(recursive: true);
  for (final e in r.ediciones) {
    final f = File(e.archivo);
    final original = f.readAsStringSync();
    File('${_resp(r).path}/${_nombreResp(e.archivo)}')
        .writeAsStringSync(original);
    f.writeAsStringSync(original.replaceFirst(e.viejo, e.nuevo));
    if (!corto)
      stdout.writeln(
          '  ${e.archivo}\n    antes:   ${e.viejo}\n    ahora:   ${e.nuevo}');
  }
  stdout.writeln('${corto ? '' : '\n'}${r.id} ${r.titulo} -> ROJO (${r.que}).');
  if (!corto) stdout.writeln('Ahora corre y captura:\n  ${r.comando}');
}

void _verde(Ronda r) {
  if (!_enRojo(r)) {
    stdout.writeln('La ${r.id} (${r.titulo}) ya estaba en verde.');
    return;
  }
  for (final e in r.ediciones) {
    final resp = File('${_resp(r).path}/${_nombreResp(e.archivo)}');
    if (resp.existsSync())
      File(e.archivo).writeAsStringSync(resp.readAsStringSync());
  }
  _resp(r).deleteSync(recursive: true);
  if (Directory(_carpeta).existsSync() &&
      Directory(_carpeta).listSync().isEmpty) {
    Directory(_carpeta).deleteSync();
  }
  stdout.writeln('${r.id} ${r.titulo} -> VERDE (archivo original restaurado).');
  stdout.writeln('Ahora corre y captura:\n  ${r.comando}');
}

void _ayuda() {
  stdout.writeln('''Uso:
  dart tool/sabotaje.dart lista
  dart tool/sabotaje.dart estado
  dart tool/sabotaje.dart rojo <ronda>    (ej. rojo 3)
  dart tool/sabotaje.dart verde <ronda>   (ej. verde 3)
  dart tool/sabotaje.dart rojo todas          (rompe todas las rondas)
  dart tool/sabotaje.dart verde           (restaura todo)''');
}

void main(List<String> args) {
  if (!File('pubspec.yaml').existsSync()) {
    stderr.writeln(
        'Corre este comando desde la carpeta raíz del proyecto (donde está pubspec.yaml).');
    exit(1);
  }
  if (args.isEmpty) return _ayuda();
  switch (args[0]) {
    case 'lista':
      for (final r in rondas) {
        stdout.writeln(
            '${r.id}  ${r.titulo}\n      rompe: ${r.que}\n      prueba: ${r.comando}\n');
      }
    case 'estado':
      for (final r in rondas) {
        stdout.writeln(
            '${r.id}  ${r.titulo.padRight(30)} ${_enRojo(r) ? "ROJO (saboteada)" : "verde"}');
      }
    case 'rojo':
      if (args.length > 1 && args[1] == 'todas') {
        for (final r in rondas) {
          _rojo(r, corto: true);
        }
        stdout.writeln(
            '\nTodo en rojo. Corre y captura:\n  flutter test -r expanded');
        return;
      }
      final r = _buscar(args.length > 1 ? args[1] : null);
      if (r == null) {
        stderr.writeln(
            'Indica una ronda entre 2 y 12. Ej: dart tool/sabotaje.dart rojo 3');
        exit(1);
      }
      _rojo(r);
    case 'verde':
      if (args.length < 2 || args[1] == 'todas') {
        for (final r in rondas) {
          if (_enRojo(r)) _verde(r);
        }
        stdout.writeln('Todo en verde.');
      } else {
        final r = _buscar(args[1]);
        if (r == null) {
          stderr.writeln('Ronda no válida.');
          exit(1);
        }
        _verde(r);
      }
    default:
      _ayuda();
  }
}
