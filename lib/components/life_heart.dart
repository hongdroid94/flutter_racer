import 'package:flame/components.dart';

class LifeHeart extends SpriteComponent {
  Sprite heartSprite;

  // 플레이어 (레이싱카) 가 최초 생성 될때 초기화 되는 값 (위치, 사이즈, 앵커)
  LifeHeart({required position, required this.heartSprite}) : super(
    position: position,
    size: Vector2.all(24),
    anchor: Anchor.topLeft,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // 스프라이트 이미지를 적용
    sprite = heartSprite;
  }
}