import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_racer/components/player.dart';

class Obstacle extends SpriteComponent with HasGameRef, CollisionCallbacks {
  Sprite obstacleSprite;

  // 플레이어 (레이싱카) 가 최초 생성 될때 초기화 되는 값 (위치, 사이즈, 앵커)
  Obstacle({required position, required this.obstacleSprite}) : super(
    position: position,
    size: Vector2.all(64),
    anchor: Anchor.bottomCenter,
  );


  @override
  Future<void> onLoad() async {
    super.onLoad();
    // sprite 적용
    sprite = obstacleSprite;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 자동으로 장애물이 이동되게.. !
    position.y = position.y + 5;
    // 화면으로 바깥으로 벗어나게 되었을 때 자동 오브젝트 삭제
    if (position.y - size.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      removeFromParent();
    } else {
      super.onCollisionStart(intersectionPoints, other);
    }
  }

}