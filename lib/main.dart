import 'package:flame/components.dart' show CameraComponent, Anchor;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:sand_sim_flt/utils/constants.dart' show screenWidth, screenHeight;
import 'package:sand_sim_flt/game/world.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GameWidget(game: SandSimulator()));
}

class SandSimulator extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Create a world component
    final world = MyWorld();

    // Create a fixed resolution camera and attach it to the world
    final camera = CameraComponent.withFixedResolution(
      width: screenWidth,
      height: screenHeight,
      world: world,
    );

    // Anchor the camera so that (0, 0) is at the top-left of the screen
    camera.viewfinder.anchor = Anchor.topLeft;

    // Add world and camera to the game
    await addAll([world, camera]);
  }
}