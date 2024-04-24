import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_racer/components/obstacle.dart';
import 'package:flame/text.dart';
import '../components/life_heart.dart';
import '../components/move_button.dart';
import '../components/player.dart';

class RacingGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  /// 게임 로직에 사용될 오브젝트 클래스 선언
  late Player player;

  late MoveButton leftMoveBtn, rightMoveBtn;
  List<LifeHeart> lifeHeartList = [];

  /// 로드 될 이미지 변수 선언
  late Sprite playerSprite;
  late Sprite obstacleSprite;
  late Sprite leftMoveButtonSprite;
  late Sprite rightMoveButtonSprite;

  int currentScore = 0; // 현재 표시되고 있는 점수
  late TextComponent scoreText; // 스코어 표시 텍스트

  double nextSpawnSeconds = 0; // 다음 장애물 생성까지의 시간
  Function onGameOver; // 게임 오버가 됬다는 것을 알려주는 콜백함수
  int playerDirection = 0; // 플레이어 이동 방향 상태 변수 (0: 정지, 1: 오른쪽, -1: 왼쪽)

  RacingGame({required this.onGameOver});

  @override
  Color backgroundColor() {
    return Color(0xffa2a2a2);
  }

  @override
  Future<void> onLoad() async {
    // 1. 스프라이트 이미지 로드
    Image playerImg = await images.load('racing_car.png');
    Image obstacleImg = await images.load('barrier.png');
    Image heartImg = await images.load('heart.png');
    Image leftMoveImg = await images.load('left.png');
    Image rightMoveImg = await images.load('right.png');

    // 2. 스프라이트 오브젝트 생성
    playerSprite = Sprite(playerImg);
    obstacleSprite = Sprite(obstacleImg);
    leftMoveButtonSprite = Sprite(leftMoveImg);
    rightMoveButtonSprite = Sprite(rightMoveImg);

    lifeHeartList.add(
      LifeHeart(
        position: Vector2(30, 60),
        heartSprite: Sprite(heartImg),
      ),
    );

    lifeHeartList.add(
      LifeHeart(
        position: Vector2(60, 60),
        heartSprite: Sprite(heartImg),
      ),
    );

    lifeHeartList.add(
      LifeHeart(
        position: Vector2(90, 60),
        heartSprite: Sprite(heartImg),
      ),
    );

    // 스코어 텍스트 컴포넌트 생성
    scoreText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 32,
          color: Color(0xff000000),
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topRight,
      position: Vector2(size.x - 60, 50),
    );

    // 3. player 생성
    player = Player(
      position: Vector2(size.x * 0.25, size.y - 20),
      playerSprite: playerSprite,
      damageCallback: onDamage,
    );

    // 4. move button 생성
    leftMoveBtn = MoveButton(
      direction: 'left',
      position: Vector2(30, size.y - 80),
      moveButtonSprite: leftMoveButtonSprite,
      onTapMoveButton: (isTapping) {
        if (isTapping) {
          playerDirection = -1;
        } else {
          playerDirection = 0;
        }
      },
    );

    rightMoveBtn = MoveButton(
      direction: 'right',
      position: Vector2(size.x - 30, size.y - 80),
      moveButtonSprite: rightMoveButtonSprite,
      onTapMoveButton: (isTapping) {
        if (isTapping) {
          playerDirection = 1;
        } else {
          playerDirection = 0;
        }
      },
    );

    // 5. 컴포넌트 추가
    add(scoreText);
    add(player);
    add(leftMoveBtn);
    add(rightMoveBtn);
    for (LifeHeart lifeHeart in lifeHeartList) {
      add(lifeHeart);
    }
    
    
    // 6. 배경음악 재생
    startBgmMusic();
    
  }
  
  @override
  void onDispose() {
    stopBgmMusic();
    super.onDispose();
  }
  

  @override
  void onTapUp(TapUpEvent event) {
    if (paused) {
      // 게임 오버 상황일때에만 내부 로직 수행
      onGameOver.call();
    }
    super.onTapUp(event);
  }

  @override
  void update(double dt) {
    super.update(dt);

    /// 장애물 랜덤 생성
    nextSpawnSeconds -= dt;
    if (nextSpawnSeconds < 0) {
      add(Obstacle(
          position: Vector2(size.x * Random().nextDouble() * 1, 0),
          obstacleSprite: obstacleSprite));
    }
    nextSpawnSeconds = 0.3 * Random().nextDouble() * 2;

    /// 스코어 증가 로직
    if (!paused) {
      currentScore++;
      scoreText.text = currentScore.toString();
    }

    /// player move 로직
    if (playerDirection == 1) {
      // 오른쪽 이동
      player.position = Vector2(
        player.position.x >= size.x - 30
            ? player.position.x
            : player.position.x + 7,
        player.position.y,
      );
    } else if (playerDirection == -1) {
      // 왼쪽 이동
      player.position = Vector2(
        player.position.x <= 30
            ? player.position.x
            : player.position.x - 7,
        player.position.y,
      );
    } else {
      // 아무 버튼도 조작하고 있지 않는 상황 (정지)
      player.position = Vector2(player.position.x, player.position.y);
    }
  }

  void onDamage() {
    // 플레이어가 데미지를 입음 , 하트 감소
    print('onDamage');
    if (lifeHeartList.isNotEmpty) {
      FlameAudio.play('sfx/car_crash.ogg');
      remove(lifeHeartList[lifeHeartList.length - 1]);
      lifeHeartList.removeLast();
      return;
    }

    // 게임 오버 (게임오버 텍스트 표시 !)
    add(
      TextComponent(
        text: 'GAME OVER\nTouch To Main',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 32,
            color: Color(0xff000000),
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2),
      ),
    );

    // 일정 딜레이 이후에 일시정지
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        paused = true;
      },
    );
  }

  void startBgmMusic() {
    // 배경음악 재생
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('music/level2.wav');
  }
  
  void stopBgmMusic() {
    // 배경음악 정지
    FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
  }
}
