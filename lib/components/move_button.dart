import 'package:flame/components.dart';
import 'package:flame/events.dart';

class MoveButton extends SpriteComponent with TapCallbacks {
  Sprite moveButtonSprite;
  Function(bool) onTapMoveButton; // 클릭 이벤트 전달 함수
  // 이동 버튼이 최초 생성 될때 초기화 되는 값 (위치, 사이즈, 앵커)
  MoveButton({
    required String direction, // 버튼 위치를 결정하기위한 방향 매개변수
    required position,
    required this.moveButtonSprite,
    required this.onTapMoveButton,
  }) : super(
          position: position,
          size: Vector2.all(64),
          anchor: direction == 'left' ? Anchor.bottomLeft : Anchor.bottomRight,
        );


  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = moveButtonSprite;
  }

  @override
  void onTapDown(TapDownEvent event) {
    // 버튼을 누르고 있을 때 !
    onTapMoveButton.call(true);
  }

  @override
  void onTapUp(TapUpEvent event) {
    // 버튼을 뗐을 때 !
    onTapMoveButton.call(false);
  }
}
