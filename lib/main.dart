import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  // Ensures Flutter widgets and Flame are properly initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Sets the app to full screen (no system UI)
  Flame.device.fullScreen();

  // Starts the game
  runApp(GameWidget(game: MyGame()));
}

// Define a 2D grid type using a list of lists of integers
typedef Grid = List<List<int>>;

// Fixed resolution for the game's screen
final _screenWidth = 400.0;
final _screenHeight = 400.0;

// Size of each cell in the grid (in pixels)
const int _pixelSize = 4;

// Grid dimension (100 x 100 grid)
const int _gridDimension = 100;

// Function to create a 2D array initialized with 0s
Grid make2DArray(int col, int row) {
  return List.generate(col, (_) => List.generate(row, (_) => 0));
}

// Main game class
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Create a world component
    final world = MyWorld();

    // Create a fixed resolution camera and attach it to the world
    final camera = CameraComponent.withFixedResolution(
      width: _screenWidth,
      height: _screenHeight,
      world: world,
    );

    // Anchor the camera so that (0, 0) is at the top-left of the screen
    camera.viewfinder.anchor = Anchor.topLeft;

    // Add world and camera to the game
    await addAll([world, camera]);
  }
}

// World class where game logic happens
class MyWorld extends World with TapCallbacks, DragCallbacks {
  // Initialize the grid
  Grid grid = make2DArray(_gridDimension, _gridDimension);

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
    final x = (gridPos.x / _pixelSize).round();
    final y = (gridPos.y / _pixelSize).round();

    // Check bounds and set cell to sand (1)
    if (x >= 0 && x < _gridDimension && y >= 0 && y < _gridDimension) {
      grid[x][y] = 1;
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

  // Called every frame to update the grid (simulate gravity)
  @override
  void update(double dt) {
    super.update(dt);

    // Create a copy of the current grid
    Grid newGrid = make2DArray(_gridDimension, _gridDimension);
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
              newGrid[i][j + 1] = 1;
              newGrid[i][j] = 0;
            } else if ((i + 1) < grid.length && (i - 1) > 0) {
              // Try diagonally left and right
              final canRight = grid[i + 1][j + 1] < 1;
              final canLeft = grid[i - 1][j + 1] < 1;

              if (canRight) {
                newGrid[i + 1][j + 1] = 1;
                newGrid[i][j] = 0;
              } else if (canLeft) {
                newGrid[i - 1][j + 1] = 1;
                newGrid[i][j] = 0;
              }
            } else {
              // If no move possible, keep it as is
              newGrid[i][j] = 1;
            }
          }
        }
      }
    }

    // Update grid with the new one
    grid = newGrid;

    // Tell visual component to re-render with updated data
    _pixelGrid.updateGrid(grid);
  }
}

// Component that visually draws the grid on screen
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
          ..color = grid[x][y] > 0 ? Colors.blue : Colors.white // Blue = sand, White = empty
          ..isAntiAlias = false;

        canvas.drawRect(
          Rect.fromLTWH(
            (x * _pixelSize).toDouble(),
            (y * _pixelSize).toDouble(),
            _pixelSize.toDouble(),
            _pixelSize.toDouble(),
          ),
          paint,
        );
      }
    }
  }
}
