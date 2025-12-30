import 'package:flutter/material.dart';
import '../../domain/entities/temperature.dart';

/// Termometre Widget'ı - Sıcaklık durumunu gösterir
class ThermometerWidget extends StatelessWidget {
  final Temperature temperature;
  final double height;

  const ThermometerWidget({
    super.key,
    required this.temperature,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Termometre arka plan
          Container(
            width: 24,
            height: height - 30,
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
          ),

          // Termometre doluluk animasyonu
          Positioned(
            bottom: 15,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              width: 20,
              height: (height - 34) * temperature.thermometerLevel,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    temperature.color,
                    temperature.color.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: temperature.color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Termometre alt balon
          Positioned(
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: temperature.color,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: temperature.color.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(temperature.icon, color: Colors.white, size: 18),
            ),
          ),

          // Seviye işaretleri
          Positioned(
            left: 35,
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLevelMark('🔥', height - 60),
                _buildLevelMark('🌡️', (height - 60) * 0.5),
                _buildLevelMark('❄️', 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelMark(String emoji, double bottom) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom > 0 ? bottom / 2 : 0),
      child: Text(emoji, style: const TextStyle(fontSize: 14)),
    );
  }
}
