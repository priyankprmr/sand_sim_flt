import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();

  runApp(GameWidget(game: MyGame()));
}

typedef Grid = List<List<int>>;

final _screenWidth = 400.0;
final _screenHeight = 400.0;

const int _pixelSize = 4;
const int _gridDimension = 100;

Grid make2DArray(int col, int row) {
  return List.generate(col, (_) => List.generate(row, (_) => 0));
}

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final world = MyWorld();
    final camera = CameraComponent.withFixedResolution(
      width: _screenWidth,
      height: _screenHeight,
      world: world,
    );
    camera.viewfinder.anchor = Anchor.topLeft;

    await addAll([world, camera]);
  }
}

class MyWorld extends World with TapCallbacks, DragCallbacks {
  Grid grid = make2DArray(_gridDimension, _gridDimension);

  late PixelGrid _pixelGrid;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    _pixelGrid = PixelGrid(grid);
    add(_pixelGrid);
  }

  void simulateSand(Vector2 gridPos) {
    final x = (gridPos.x / _pixelSize).round();
    final y = (gridPos.y / _pixelSize).round();

    if (x >= 0 && x < _gridDimension && y >= 0 && y < _gridDimension) {
      grid[x][y] = 1;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    simulateSand(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    simulateSand(event.localStartPosition);
  }

  @override
  void update(double dt) {
    super.update(dt);
    Grid newGrid = make2DArray(_gridDimension, _gridDimension);
    for (var i = 0; i < grid.length; i++) {
      for (var j = 0; j < grid[i].length; j++) {
        newGrid[i][j] = grid[i][j];
      }
    }
    for (var i = 0; i < grid.length; i++) {
      for (var j = 0; j < grid[i].length; j++) {
        final state = grid[i][j];
        if (state > 0) {
          if ((j + 1) < grid.length) {
            final below = grid[i][j + 1];
            if (below < 1) {
              newGrid[i][j + 1] = 1;
              newGrid[i][j] = 0;
            } else if ((i + 1) < grid.length && (i - 1) > 0) {
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
              newGrid[i][j] = 1;
            }
          }
        }
      }
    }
    grid = newGrid;
    _pixelGrid.updateGrid(grid);
  }
}

class PixelGrid extends Component {
  Grid grid;
  PixelGrid(this.grid);

  void updateGrid(Grid newGrid) {
    grid = newGrid;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (var x = 0; x < grid.length; x++) {
      for (var y = 0; y < grid[x].length; y++) {
        final paint = Paint()
          ..color = grid[x][y] > 0 ? Colors.blue : Colors.white
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
