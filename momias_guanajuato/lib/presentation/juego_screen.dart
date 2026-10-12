import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logica/motor_juego.dart';
import '../logica/personaje.dart';
import '../logica/momia.dart';
import '../logica/calaverita.dart';
import '../logica/rectangulo.dart';
import '../logica/estado_juego.dart';

class JuegoScreen extends StatefulWidget {
  const JuegoScreen({super.key});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> {
  late MotorJuego _motor;
  Timer? _bucle;
  double _direccion = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _iniciarNivel();
    _iniciarBucle();
  }

  void _iniciarNivel() {
    _motor = MotorJuego(
      personaje: Personaje(x: 20, y: 100),
      plataformas: const [
        // Suelo principal
        Rectangulo(x: 0, y: 300, ancho: 2000, alto: 40),
        // Plataformas elevadas
        Rectangulo(x: 300, y: 220, ancho: 120, alto: 20),
        Rectangulo(x: 550, y: 160, ancho: 120, alto: 20),
        Rectangulo(x: 750, y: 230, ancho: 100, alto: 20),
        Rectangulo(x: 1000, y: 190, ancho: 140, alto: 20),
        Rectangulo(x: 1300, y: 210, ancho: 120, alto: 20),
        Rectangulo(x: 1600, y: 170, ancho: 120, alto: 20),
      ],
      momias: [
        Momia(x: 320, y: 268, limiteIzquierdo: 300, limiteDerecho: 420),
        Momia(x: 900, y: 268, limiteIzquierdo: 850, limiteDerecho: 1100),
        Momia(x: 1400, y: 268, limiteIzquierdo: 1300, limiteDerecho: 1600),
      ],
      calaveritas: [
        Calaverita(x: 360, y: 180),
        Calaverita(x: 600, y: 120),
        Calaverita(x: 1200, y: 260),
        Calaverita(x: 1050, y: 150),
        Calaverita(x: 1650, y: 130),
      ],
      posicionMeta: 1900,
      anchoNivel: 2000,
    );
  }

  void _iniciarBucle() {
    _bucle?.cancel();
    _bucle = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() => _motor.mover(_direccion * 4));
      if (_motor.estado != EstadoJuego.jugando) {
        _bucle?.cancel();
        _mostrarResultado();
      }
    });
  }

  @override
  void dispose() {
    _bucle?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        setState(() => _direccion = -1);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        setState(() => _direccion = 1);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _motor.saltar();
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      if ((event.logicalKey == LogicalKeyboardKey.arrowLeft ||
              event.logicalKey == LogicalKeyboardKey.keyA) &&
          _direccion == -1) {
        setState(() => _direccion = 0);
        return KeyEventResult.handled;
      } else if ((event.logicalKey == LogicalKeyboardKey.arrowRight ||
              event.logicalKey == LogicalKeyboardKey.keyD) &&
          _direccion == 1) {
        setState(() => _direccion = 0);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _mostrarResultado() {
    final gano = _motor.estado == EstadoJuego.ganado;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'resultado',
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
        child: FadeTransition(
          opacity: anim1,
          child: AlertDialog(
            backgroundColor: gano
                ? const Color(0xFF1A237E)
                : const Color(0xFF4A148C),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                Text(
                  gano ? '🎉' : '💀',
                  style: const TextStyle(fontSize: 48),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  gano
                      ? '¡Llegaste al\nCallejón del Beso!'
                      : '¡Las momias\nte atraparon!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Puntaje: ${_motor.puntaje}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text('Jugar de nuevo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(_iniciarNivel);
                    _iniciarBucle();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final anchoVentana = screenWidth;
    final camaraX = (_motor.personaje.x - anchoVentana / 2)
        .clamp(0.0, (_motor.anchoNivel - anchoVentana).clamp(0.0, double.infinity));

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: SafeArea(
          child: Column(
            children: [
              // HUD
              _buildHUD(),
              // Área de juego
              Expanded(
                child: ClipRect(
                  child: Stack(
                    children: [
                      // Fondo con gradiente cielo de Guanajuato
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1A0533),
                                Color(0xFF3D1068),
                                Color(0xFF7B2D8B),
                                Color(0xFFFF6B35),
                              ],
                              stops: [0.0, 0.3, 0.65, 1.0],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Estrellas decorativas (fijas)
                      ..._buildEstrellas(),
                      // META — Callejón del Beso
                      Positioned(
                        left: 1900 - camaraX,
                        top: 180,
                        child: _buildMeta(),
                      ),
                      // Plataformas
                      ..._motor.plataformas.map((pl) => Positioned(
                            left: pl.x - camaraX,
                            top: pl.y,
                            child: _buildPlataforma(pl.ancho, pl.alto,
                                esSuelo: pl.alto == 40),
                          )),
                      // Calaveritas
                      ..._motor.calaveritas
                          .where((c) => !c.recolectada)
                          .map((c) => Positioned(
                                left: c.x - camaraX,
                                top: c.y,
                                child: _buildCalaverita(),
                              )),
                      // Momias
                      ..._motor.momias
                          .where((m) => !m.derrotada)
                          .map((m) => Positioned(
                                left: m.x - camaraX,
                                top: m.y,
                                child: _buildMomia(m),
                              )),
                      // Personaje
                      Positioned(
                        left: _motor.personaje.x - camaraX,
                        top: _motor.personaje.y,
                        child: _buildPersonaje(),
                      ),
                    ],
                  ),
                ),
              ),
              // Controles
              _buildControles(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0533), Color(0xFF2D0D4E)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Vidas
          Row(
            children: [
              const Text('❤️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              ...List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    i < _motor.vidas ? Icons.favorite : Icons.favorite_border,
                    color: i < _motor.vidas
                        ? Colors.pinkAccent
                        : Colors.white24,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          // Título
          const Text(
            'Momias de Guanajuato',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          // Puntaje
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.pinkAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pinkAccent, width: 1),
            ),
            child: Row(
              children: [
                const Text('💀', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${_motor.puntaje}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEstrellas() {
    final posiciones = [
      [30.0, 20.0],
      [100.0, 10.0],
      [180.0, 35.0],
      [250.0, 15.0],
      [310.0, 40.0],
    ];
    return posiciones
        .map((p) => Positioned(
              left: p[0],
              top: p[1],
              child: const Icon(Icons.star, color: Colors.white24, size: 6),
            ))
        .toList();
  }

  Widget _buildPlataforma(double ancho, double alto, {bool esSuelo = false}) {
    return Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: esSuelo
              ? [const Color(0xFF8B0057), const Color(0xFFAD1457)]
              : [const Color(0xFFE91E63), const Color(0xFFF48FB1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(esSuelo ? 0 : 6),
        border: Border.all(color: Colors.white30, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: esSuelo
          ? Row(
              children: List.generate(
                (ancho / 40).ceil(),
                (i) => Container(
                  width: 40,
                  height: alto,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                          color: Colors.white.withOpacity(0.15), width: 1),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCalaverita() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber.withOpacity(0.15),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text('💀', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildMomia(Momia m) {
    return Container(
      width: m.ancho,
      height: m.alto,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFEBE9), Color(0xFFD7CCC8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text('🧟', style: TextStyle(fontSize: 20)),
    );
  }

  Widget _buildPersonaje() {
    return Container(
      width: _motor.personaje.ancho,
      height: _motor.personaje.alto,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text('🤠', style: TextStyle(fontSize: 20)),
    );
  }

  Widget _buildMeta() {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.7),
                blurRadius: 16,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Column(
            children: [
              Text('💋', style: TextStyle(fontSize: 24)),
              Text(
                'Callejón\ndel Beso',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A0533),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControles() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D0D0D), Color(0xFF1A0533)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botones de dirección
          Row(
            children: [
              _boton(
                icon: Icons.arrow_back_ios_rounded,
                label: '',
                onPress: () => _direccion = -1,
                onRelease: () => _direccion = 0,
                color: const Color(0xFF3949AB),
              ),
              const SizedBox(width: 12),
              _boton(
                icon: Icons.arrow_forward_ios_rounded,
                label: '',
                onPress: () => _direccion = 1,
                onRelease: () => _direccion = 0,
                color: const Color(0xFF3949AB),
              ),
            ],
          ),
          // Botón de salto
          _boton(
            icon: Icons.keyboard_arrow_up_rounded,
            label: 'SALTO',
            onPress: () => _motor.saltar(),
            onRelease: () {},
            color: const Color(0xFFE91E63),
            size: 34,
          ),
        ],
      ),
    );
  }

  Widget _boton({
    required IconData icon,
    required String label,
    required VoidCallback onPress,
    required VoidCallback onRelease,
    required Color color,
    double size = 28,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPress(),
      onTapUp: (_) => onRelease(),
      onTapCancel: onRelease,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
          ),
          border: Border.all(color: Colors.white24, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
