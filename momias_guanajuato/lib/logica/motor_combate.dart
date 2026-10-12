import 'personaje.dart';
import 'momia.dart';
import 'motor_fisica.dart';

enum ResultadoColisionMomia { ninguna, momiaDerrotada, jugadorGolpeado }

class MotorCombate {
  /// Verifica si dos rectángulos se solapan, incluyendo contacto en borde (>=).
  static bool _seSolapan(Personaje p, Momia m) {
    return p.x < m.x + m.ancho &&
        p.x + p.ancho > m.x &&
        p.y < m.y + m.alto &&
        p.y + p.alto >= m.y; // >= para incluir contacto exacto en borde
  }

  static ResultadoColisionMomia resolverColision(
      Personaje personaje, Momia momia) {
    if (momia.derrotada) return ResultadoColisionMomia.ninguna;
    if (!_seSolapan(personaje, momia)) {
      return ResultadoColisionMomia.ninguna;
    }

    final cayendoSobreLaMomia = personaje.velocidadY > 0 &&
        (personaje.y + personaje.alto) <= (momia.y + momia.alto / 2);

    if (cayendoSobreLaMomia) {
      momia.derrotada = true;
      personaje.velocidadY = MotorFisica.impulsoSalto / 2; // rebote
      return ResultadoColisionMomia.momiaDerrotada;
    }

    return ResultadoColisionMomia.jugadorGolpeado;
  }
}
