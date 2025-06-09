// World class where game logic happens
import 'dart:async' show FutureOr;
import 'dart:math' show Random;

import 'package:flame/components.dart';
import 'package:flame/events.dart'
    show TapCallbacks, DragCallbacks, TapDownEvent, DragUpdateEvent;
import 'package:sand_sim_flt/utils/constants.dart';
import 'package:sand_sim_flt/game/pixel_grid.dart';
import 'package:sand_sim_flt/utils/typedefs.dart';

// Function to create a 2D array initialized with 0s
Grid _make2DArray() {
  return List.generate(col, (_) => List.generate(row, (_) => 0));
}

class MyWorld extends World with TapCallbacks, DragCallbacks {
  // Initialize the grid
  Grid grid = _make2DArray();

  // Component to render the grid
  late PixelGrid _pixelGrid;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();

    // Create and add the visual grid component
    _pixelGrid = PixelGrid(grid);
    add(_pixelGrid);
  }

  // Set a cell to 1 when tapped or dragged (drop sand)
  void simulateSand(Vector2 gridPos) {
    final matrix = 3;
    final extent = (matrix / 2).round();

    for (var i = -extent; i <= extent; i++) {
      for (var j = -extent; j < extent; j++) {
        final x = ((gridPos.x / pixelSize).round() + i);
        final y = ((gridPos.y / pixelSize).round() + j);
        // Check bounds and set cell to sand (1)
        if (x >= 0 && x < col && y >= 0 && y < row) {
          grid[x][y] = hueValue;
        }
      }
    }
  }

  // Handle tap events to simulate sand
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    simulateSand(event.localPosition);
  }

  // Handle drag events to simulate sand
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    simulateSand(event.localStartPosition);
  }

  int hueValue = 100;

  // Called every frame to update the grid (simulate gravity)
  @override
  void update(double dt) {
    super.update(dt);

    // Create a copy of the current grid
    Grid newGrid = _make2DArray();
    for (var i = 0; i < grid.length; i++) {
      for (var j = 0; j < grid[i].length; j++) {
        newGrid[i][j] = grid[i][j];
      }
    }

    // Loop through grid and simulate sand falling down
    for (var i = 0; i < grid.length; i++) {
      for (var j = 0; j < grid[i].length; j++) {
        final state = grid[i][j];

        // If cell has sand
        if (state > 0) {
          // Check if cell below is empty
          if ((j + 1) < grid.length) {
            final below = grid[i][j + 1];

            if (below < 1) {
              // Move sand down
              newGrid[i][j + 1] = state;
              newGrid[i][j] = 0;
            } else if ((i + 1) < grid.length && (i - 1) > 0) {
              // Try diagonally left and right
              final canRight = grid[i + 1][j + 1] < 1;
              final canLeft = grid[i - 1][j + 1] < 1;

              // If can go to both left and right, pick random side
              if (canRight && canLeft) {
                if (Random().nextBool()) {
                  newGrid[i + 1][j + 1] = state;
                  newGrid[i][j] = 0;
                } else {
                  newGrid[i - 1][j + 1] = state;
                  newGrid[i][j] = 0;
                }
              } else if (canRight) {
                newGrid[i + 1][j + 1] = state;
                newGrid[i][j] = 0;
              } else if (canLeft) {
                newGrid[i - 1][j + 1] = state;
                newGrid[i][j] = 0;
              }
            } else {
              // If no move possible, keep it as is
              newGrid[i][j] = state;
            }
          }
        }
      }
    }

    // Update grid with the new one
    grid = newGrid;

    // Tell visual component to re-render with updated data
    _pixelGrid.updateGrid(grid);

    hueValue += 1;
    if (hueValue >= 360) {
      hueValue = 1;
    }
  }
}
