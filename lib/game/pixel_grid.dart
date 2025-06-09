// Component that visually draws the grid on screen
import 'dart:ui';

import 'package:flame/components.dart' show Component;
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/painting.dart' show HSVColor;
import 'package:sand_sim_flt/utils/constants.dart' show pixelSize;
import 'package:sand_sim_flt/utils/typedefs.dart';

class PixelGrid extends Component {
  Grid grid;
  PixelGrid(this.grid);

  // Called when simulation updates the grid
  void updateGrid(Grid newGrid) {
    grid = newGrid;
  }

  // Render the grid as colored pixels
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (var x = 0; x < grid.length; x++) {
      for (var y = 0; y < grid[x].length; y++) {
        final paint = Paint()
          ..color = grid[x][y] > 0
              ? HSVColor.fromAHSV(
                  1.0,
                  (grid[x][y]).toDouble(),
                  1.0,
                  1.0,
                ).toColor()
              : Colors.white
          ..isAntiAlias = false;

        canvas.drawRect(
          Rect.fromLTWH(
            (x * pixelSize).toDouble(),
            (y * pixelSize).toDouble(),
            pixelSize.toDouble(),
            pixelSize.toDouble(),
          ),
          paint,
        );
      }
    }
  }
}
