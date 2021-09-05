package;

import flixel.ui.FlxSpriteButton;
import flixel.addons.ui.FlxUISpriteButton;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIGroup;
import openfl.Lib;
#if windows
import llua.Lua;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	#if android
	var grpMenuButt:FlxTypedGroup<FlxUIButton>;
	#else
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	#end

	var menuItems:Array<String> = ['resume', 'restart song', 'exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var perSongOffset:FlxText;
	
	var offsetChanged:Bool = false;

	public function new(x:Float, y:Float)
	{
		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		#if android
		grpMenuButt = new FlxTypedGroup<FlxUIButton>();
		add(grpMenuButt);
		#else
		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		#end

		perSongOffset = new FlxText(5, FlxG.height - 18, 0, "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.', 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		#if windows
			add(perSongOffset);
		#end

		for (i in 0...menuItems.length)
		{
			#if android
			var menuTextSpr:FlxSprite = new FlxSprite();
			menuTextSpr.frames = Paths.getSparrowAtlas('pause_menu_spr');
			menuTextSpr.animation.addByPrefix("idle", menuItems[i], 24, true);
			menuTextSpr.animation.play("idle");

			var menuTouch:FlxUIButton = new FlxUIButton(0, (150 * i) + FlxG.height/2);
			menuTouch.loadGraphic(Paths.image("pauseSpr/" + menuItems[i]));
			menuTouch.ID = i;
			menuTouch.screenCenter(X);
			menuTouch.alpha = 0;
			FlxTween.tween(menuTouch, {y: (150 * i) + 150, alpha: 1}, 0.4 * (i+1), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween) {
				canTouch = true;
			}});
			grpMenuButt.add(menuTouch);
			#else
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.ID = i;
			grpMenuShit.add(songText);
			#end

			
		}

		#if !android
		// changeSelection();
		#end

		// #if android
		// addVirtualPad(UP_DOWN, A_B);
		// #end

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	function eachStuff(#if android f:FlxUIButton #else cur:Int #end) {
		switch (#if android f.ID #else cur #end)
		{
			case 0:
				close();
			case 1:
				FlxG.resetState();
			case 2:
				#if windows
					if(PlayState.loadRep)
					{
						FlxG.save.data.botplay = false;
						FlxG.save.data.scrollSpeed = 1;
						FlxG.save.data.downscroll = false;
					}

					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					if (FlxG.save.data.fpsCap > 290)
						(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
					#end

					PlayState.loadRep = false;
					if (PlayState.isStoryMode){
						FlxG.switchState(new StoryMenuState());
					}
					else{
						FlxG.switchState(new FreeplayState());
					}
		}
	}
	var canTouch = false;

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		#if android
		grpMenuButt.forEach(function(f:FlxUIButton) {
			if (f.justPressed && canTouch){
				eachStuff(f);
			}
		});

		#else

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		
		var accepted = controls.ACCEPT;
		
		if (upP)
		{
			changeSelection(-1);
   
		}else if (downP)
		{
			changeSelection(1);
		}
		
		#if windows
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var oldOffset:Float = 0;
		var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';
		else if (leftP)
		{
			oldOffset = PlayState.songOffset;
			PlayState.songOffset -= 1;
			sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
			perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';

			// Prevent loop from happening every single time the offset changes
			if(!offsetChanged)
			{
				grpMenuShit.clear();

				menuItems = ['Restart Song', 'Exit to menu'];

				for (i in 0...menuItems.length)
				{
					var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
					songText.isMenuItem = true;
					songText.targetY = i;
					grpMenuShit.add(songText);
				}

				changeSelection();

				cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				offsetChanged = true;
			}
		}else if (rightP)
		{
			oldOffset = PlayState.songOffset;
			PlayState.songOffset += 1;
			sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
			perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';
			if(!offsetChanged)
			{
				grpMenuShit.clear();

				menuItems = ['Restart Song', 'Exit to menu'];

				for (i in 0...menuItems.length)
				{
					var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
					songText.isMenuItem = true;
					songText.targetY = i;
					grpMenuShit.add(songText);
				}

				changeSelection();

				cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				offsetChanged = true;
			}
		} #end

		if (accepted)
		{
			eachStuff(curSelected);
		}
		#end
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	#if !android
	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
	#end
}