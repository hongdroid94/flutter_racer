import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'obstacle.dart';

// 레이싱 카 오브젝트
class Player extends SpriteComponent with CollisionCallbacks {
  Sprite playerSprite;
  final VoidCallback damageCallback;

  // 플레이어 (레이싱카) 가 최초 생성 될때 초기화 되는 값 (위치, 사이즈, 앵커)
  Player({required position, required this.playerSprite, required this.damageCallback}) : super(
    position: position,
    size: Vector2.all(48),
    anchor: Anchor.bottomCenter,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // 스프라이트 이미지를 적용
    sprite = playerSprite;

    // 충돌감지 컴포넌트를 레이싱카에 적용
    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    // 충돌 대상이 장애물인 경우에만 데미지 입었다는 처리를 게임 전체에 알림
    if (other is Obstacle) {
      damageCallback.call();
    } else {
      super.onCollisionStart(intersectionPoints, other);
    }
  }
}