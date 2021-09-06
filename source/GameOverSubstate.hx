package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.ui.FlxUIButton;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	var backB:FlxUIButton;

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (PlayState.SONG.player1)
		{
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		#if android
		backB = new FlxUIButton(50, 50);
		backB.loadGraphic(Paths.image("back_white"));
		backB.scrollFactor.set();
		add(backB);
		backB.alpha = 0;
		#end

	}

	var yeaTouchIt:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var yea = controls.ACCEPT;
		var nah = controls.BACK #if android || FlxG.android.justReleased.BACK || backB.justPressed #end;
		
		if (yeaTouchIt && !isEnding)
		{
			#if android
			for (touch in FlxG.touches.list)
			{
				if (touch.justPressed && !backB.justPressed)
				{
					yea = true;
				}
			}
			#end

			if (yea)
			{
				endBullshit();
			}

			if (nah)
			{
				FlxG.sound.music.stop();

				if (PlayState.isStoryMode)
					FlxG.switchState(new StoryMenuState());
				else
					FlxG.switchState(new FreeplayState());
				PlayState.loadRep = false;
			}
		}
		

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			yeaTouchIt = true;
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			FlxTween.tween(backB, {alpha: 1}, Conductor.crochet/1000, {ease: FlxEase.quadOut});
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		isEnding = true;
		bf.playAnim('deathConfirm', true);
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
		});
		
	}
}
