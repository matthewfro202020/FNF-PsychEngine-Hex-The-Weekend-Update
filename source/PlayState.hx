package;

import HEXDialougeState;
import flixel.util.FlxSpriteUtil;
#if FEATURE_LUAMODCHART
import LuaClass.LuaCamera;
import LuaClass.LuaCharacter;
import LuaClass.LuaNote;
#end
import lime.media.openal.AL;
import Song.Event;
import openfl.media.Sound;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.io.File;
import Sys;
import sys.FileSystem;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
#if FEATURE_WEBM
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SongData;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var SONG:SongData;
	public static var reactiveSONG:SongData;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public var addedBotplay:Bool = false;

	public var visibleNotes:Array<Note> = [];

	public static var songPosBar:FlxBar;

	public var beatCutoff:Float = 16;

	public var lScrl:Array<Float> = [];

	public static var noteskinSprite:FlxAtlasFrames;
	public static var noteskinPixelSprite:BitmapData;
	public static var noteskinPixelSpriteEnds:BitmapData;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var glitcherDad:Character;
	public static var glitcherBF:Boyfriend;
	public static var glitcherStage:FlxSprite;

	public static var glitcherRDad:Character;
	public static var glitcherRBF:Boyfriend;

	public static var coolingDad:Character;
	public static var coolingGF:Character;
	public static var coolingBF:Boyfriend;

	public static var lcdDad2:Character;
	public static var lcdGF2:Character;
	public static var lcdBF2:Boyfriend;

	public static var lcdDad3:Character;
	public static var lcdGF3:Character;
	public static var lcdBF3:Boyfriend;

	public static var glitched:Bool = false;
	public static var dark:Bool = false;

	public var doMoveArrows = false;

	public static var inDaPlay:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	public var reactiveNotes:Array<Array<Dynamic>> = [];

	#if FEATURE_DISCORD
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if FEATURE_STEPMANIA
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public static var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public static var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public static var cpuStrums:FlxTypedGroup<StaticArrow> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	private var camGame:FlxCamera;

	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)
	var forcedToIdle:Bool = false; // change if bf and dad are forced to idle to every (idleBeat) beats of the song
	var allowedToHeadbang:Bool = true; // Will decide if gf is allowed to headbang depending on the song
	var allowedToCheer:Bool = false; // Will decide if gf is allowed to cheer depending on the song

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var songName:FlxText;

	var altSuffix:String = "";

	public var currentSection:SwagSection;

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public static var currentSong = "noneYet";

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var judgementCounter:FlxText;
	var replayTxt:FlxText;

	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText;
	var skipTo:Float;

	public static var campaignScore:Int = 0;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var stageTesting:Bool = false;

	var camPos:FlxPoint;

	public var randomVar = false;

	public static var Stage:Stage;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	public var coolingVideo:FlxSprite;

	public var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	public var restartedSong:Bool = false;

	public function restart()
	{
		Conductor.songPosition = 0;
		restartedSong = true;
		startedCountdown = false;
		boyfriend.stunned = false;
		persistentUpdate = true;
		persistentDraw = true;
		paused = false;
		for (i in members)
		{
			remove(i);
		}
		if (luaModchart != null)
			luaModchart.die();
		songScoreDef = 0;
		songScore = 0;
		unspawnNotes = [];
		notes.clear();
		totalNotesHit = 0;
		totalPlayed = 0;
		songTime = 0;
		combo = 0;
		accuracy = 0;
		startingSong = false;
		health = 1;

		create();
	}

	var superCreateCalled:Bool = false;

	override public function load()
	{
		PauseSubState.FUCKINGDONTDOITVLCMEDIAPLAYERISWEARTOGOD = false;

		coolingDad = null;
		coolingBF = null;
		coolingGF = null;
		lcdGF2 = null;
		lcdGF3 = null;
		lcdBF3 = null;
		lcdBF2 = null;
		lcdDad2 = null;
		lcdDad3 = null;
		glitcherRDad = null;
		glitcherRBF = null;

		GameplayCustomizeState.freeplayBf = SONG.player1;
		GameplayCustomizeState.freeplayDad = SONG.player2;
		GameplayCustomizeState.freeplayGf = SONG.gfVersion;
		GameplayCustomizeState.freeplayNoteStyle = SONG.noteStyle;
		GameplayCustomizeState.freeplayStage = SONG.stage;
		GameplayCustomizeState.freeplaySong = SONG.songId;
		GameplayCustomizeState.freeplayWeek = storyWeek;
		Debug.logTrace("load called, we're loading..");
		LoadingScreen.progress += 10;
		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', '');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Conductor.bpm = SONG.bpm;

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change")];
		}

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				var bpm = i.value * songMultiplier;

				TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
					var step = ((60 / data.bpm) * 1000) / 4;
					TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
				}

				currentIndex++;
			}
		}

		recalculateAllSectionTimes();

		LoadingScreen.progress += 40;

		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 4:
					gfCheck = 'gf-car';
				case 5:
					gfCheck = 'gf-christmas';
				case 6:
					gfCheck = 'gf-pixel';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		gf = new Character(400, 130, gfCheck);

		LoadingScreen.progress += 10;

		if (gf.frames == null)
		{
			#if debug
			FlxG.log.warn(["Couldn't load gf: " + gfCheck + ". Loading default gf"]);
			#end
			gf = new Character(400, 130, 'gf');
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		LoadingScreen.progress += 10;

		if (boyfriend.frames == null)
		{
			#if debug
			FlxG.log.warn(["Couldn't load boyfriend: " + SONG.player1 + ". Loading default boyfriend"]);
			#end
			boyfriend = new Boyfriend(770, 450, 'bf');
		}

		dad = new Character(100, 100, SONG.player2);

		LoadingScreen.progress += 10;

		if (dad.frames == null)
		{
			#if debug
			FlxG.log.warn(["Couldn't load opponent: " + SONG.player2 + ". Loading default opponent"]);
			#end
			dad = new Character(100, 100, 'dad');
		}

		Debug.logTrace("creating stage");

		LoadingScreen.progress += 20;

		super.load();
	}

	public var dadWidth:Float = 0;

	override public function create()
	{
		Stage = new Stage(SONG.stage);
		Debug.logTrace(loadedCompletely + " - loaded");
		FlxG.mouse.visible = false;
		instance = this;

		previousRate = songMultiplier - 0.05;

		if (previousRate < 1.00)
			previousRate = 1;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		inDaPlay = true;

		if (currentSong != SONG.songName)
		{
			currentSong = SONG.songName;
		}

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed * songMultiplier;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;

		removedVideo = false;

		#if FEATURE_LUAMODCHART
		// TODO: Refactor this to use OpenFlAssets.
		executeModchart = FileSystem.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart'));
		if (isSM)
			executeModchart = FileSystem.exists(pathToSm + "/modchart.lua");
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		Debug.logInfo('Searching for mod chart? ($executeModchart) at ${Paths.lua('songs/${PlayState.SONG.songId}/modchart')}');

		if (executeModchart)
		{
			songMultiplier = 1;
			PlayStateChangeables.scrollSpeed = 1.8;
			PlayStateChangeables.useDownscroll = false;
		}

		lScrl = [];

		for (i in 0...8)
		{
			lScrl.push(PlayStateChangeables.scrollSpeed);
		}

		#if FEATURE_DISCORD
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.songName
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.height = 1300;
		camNotes.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);
		FlxG.cameras.add(camHUD);

		camHUD.zoom = PlayStateChangeables.zoom;

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// if the song has dialogue, so we don't accidentally try to load a nonexistant file and crash the game
		if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue')))
		{
			dialogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue'));
		}

		if (isStoryMode)
			songMultiplier = 1;

		if (Stage.curStage == "hexw" && SONG.songId.toLowerCase() == "cooling")
		{
			coolingVideo = new FlxSprite(-24, -224);
			coolingVideo.antialiasing = true;
			coolingVideo.scrollFactor.set(0.9, 0.9);
			add(coolingVideo);

			Debug.logTrace("starting vis");
			if (coolingHandler == null)
			{
				coolingHandler = new MP4Handler();
				coolingHandler.playMP4(Paths.video('coolingVisualizer'), null, coolingVideo, false, false, true);
			}
			else
			{
				coolingVideo.loadGraphic(coolingHandler.bitmap.bitmapData);

				coolingVideo.setGraphicSize(945, 472);
				var perecentSupposed = (FlxG.sound.music.time / songMultiplier) / (FlxG.sound.music.length / songMultiplier);
				coolingHandler.bitmap.seek(perecentSupposed); // I laughed my ass off so hard when I found out this was a fuckin PERCENTAGE
				coolingHandler.bitmap.resume();
			}
			coolingVideo.alpha = 0;
		}

		for (i in Stage.toAdd)
		{
			add(i);
		}

		if (Stage.curStage == "hexwstage")
		{
			add(Stage.swagBacks['hexFront1']);
			add(Stage.swagBacks['hexFront2']);
			add(Stage.swagBacks['hexFront3']);
		}

		if (!PlayStateChangeables.Optimize)
			for (index => array in Stage.layInFront)
			{
				switch (index)
				{
					case 0:
						add(gf);
						if (Stage.curStage == 'hexw' || Stage.curStage == "hexwd" || Stage.curStage == "hexwdg" || Stage.curStage == "hexwstage")
						{
							gf.setGraphicSize(Std.int(gf.width * 0.75));
							if (coolingGF != null)
							{
								add(coolingGF);
								coolingGF.setGraphicSize(Std.int(coolingGF.width * 0.75));
							}
							if (lcdGF2 != null)
							{
								add(lcdGF2);
								lcdGF2.setGraphicSize(Std.int(lcdGF2.width * 0.75));
							}
							if (lcdGF3 != null)
							{
								add(lcdGF3);
								lcdGF3.setGraphicSize(Std.int(lcdGF3.width * 0.75));
							}
						}
						gf.scrollFactor.set(0.95, 0.95);
						for (bg in array)
							add(bg);
					case 1:
						add(dad);
						for (bg in array)
							add(bg);
						if (Stage.curStage == 'hexw' || Stage.curStage == "hexwd" || Stage.curStage == "hexwdg" || Stage.curStage == "hexwstage")
						{
							if (dadWidth != dad.width)
							{
								dad.setGraphicSize(Std.int(dad.width * 0.75));
								dadWidth = dad.width;
								if (coolingDad != null)
								{
									add(coolingDad);
									coolingDad.setGraphicSize(Std.int(coolingDad.width * 0.75));
								}
								if (lcdDad2 != null)
								{
									add(lcdDad2);
									lcdDad2.setGraphicSize(Std.int(lcdDad2.width * 0.75));
								}
								if (lcdDad3 != null)
								{
									add(lcdDad3);
									lcdDad3.setGraphicSize(Std.int(lcdDad3.width * 0.75));
								}
							}
						}
						if (Stage.curStage == "hexwdg")
						{
							add(glitcherRDad);
							glitcherRDad.alpha = 0;
							glitcherRDad.setGraphicSize(Std.int(glitcherRDad.width * 0.75));
						}
						if (Stage.curStage == 'hexg')
						{
							add(glitcherDad);
							dad.y += 150;
							glitcherDad.y += 150;
						}
					case 2:
						add(boyfriend);
						for (bg in array)
							add(bg);
						if (Stage.curStage == 'hexw' || Stage.curStage == "hexwd" || Stage.curStage == "hexwdg" || Stage.curStage == "hexwstage")
						{
							boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
							if (coolingBF != null)
							{
								add(coolingBF);
								coolingBF.setGraphicSize(Std.int(coolingBF.width * 0.75));
							}
							if (lcdBF2 != null)
							{
								add(lcdBF2);
								lcdBF2.setGraphicSize(Std.int(lcdBF2.width * 0.75));
							}
							if (lcdBF3 != null)
							{
								add(lcdBF3);
								lcdBF3.setGraphicSize(Std.int(lcdBF3.width * 0.75));
							}
						}
						if (Stage.curStage == "hexwdg")
						{
							add(glitcherRBF);
							glitcherRBF.alpha = 0;
							glitcherRBF.setGraphicSize(Std.int(glitcherRBF.width * 0.75));
						}
						if (Stage.curStage == 'hexg')
						{
							add(glitcherBF);
						}
				}
			}

		if (Stage.curStage == "hexw" || Stage.curStage == "hexwd" || Stage.curStage == "hexwdg")
		{
			add(Stage.swagBacks['crowd']);
			add(Stage.swagBacks['topOverlay']);
		}

		if (Stage.curStage == "hexwstage")
		{
			bopOn = 2;
			Stage.swagBacks['crowd2'].alpha = 0;
			Stage.swagBacks['crowd3'].alpha = 0;
			Stage.swagBacks['lights2'].alpha = 0;
			Stage.swagBacks['lights3'].alpha = 0;
			Stage.swagBacks['hexBack2'].alpha = 0;
			Stage.swagBacks['hexBack3'].alpha = 0;
			Stage.swagBacks['hexFront2'].alpha = 0;
			Stage.swagBacks['hexFront3'].alpha = 0;
			add(Stage.swagBacks['crowd1']);
			add(Stage.swagBacks['crowd2']);
			add(Stage.swagBacks['crowd3']);
		}
		for (bg in Stage.appearInFront)
		{
			add(bg);
		}

		if (Stage.curStage == "hexw")
		{
			add(Stage.swagBacks['darkCrowd']);
			add(Stage.swagBacks['darkOverlay']);
		}

		var positions = Stage.positions[Stage.curStage];
		if (positions != null && !stageTesting)
		{
			for (char => pos in positions)
				for (person in [boyfriend, gf, dad])
					if (person.curCharacter == char)
						person.setPosition(pos[0], pos[1]);
		}

		start();

		if (!superCreateCalled)
		{
			superCreateCalled = true;
			super.create();
		}
	}

	function start()
	{
		var hexDiag:HEXDialogueBox = null;

		if (isStoryMode && !restartedSong)
		{
			switch (Stage.curStage)
			{
				case 'hex':
					var sprite = new FlxSprite(-340, -190).loadGraphic(Paths.image('cutscenes/CUT1', 'hex'));
					sprite.antialiasing = true;
					sprite.setGraphicSize(Std.int(sprite.width * 0.8));
					hexDiag = new HEXDialogueBox(false, dialogue, sprite);
				case 'hexss':
					var sprite = new FlxSprite(-340, -190).loadGraphic(Paths.image('cutscenes/CUT7', 'hex'));
					sprite.antialiasing = true;
					sprite.setGraphicSize(Std.int(sprite.width * 0.8));
					hexDiag = new HEXDialogueBox(false, dialogue, sprite);
				case 'hexn':
					var sprite = new FlxSprite(-340, -190).loadGraphic(Paths.image('cutscenes/CUT10', 'hex'));
					sprite.antialiasing = true;
					sprite.setGraphicSize(Std.int(sprite.width * 0.8));
					hexDiag = new HEXDialogueBox(false, dialogue, sprite);
				case 'hexg':
					var sprite = new FlxSprite(-340, -190).loadGraphic(Paths.image('cutscenes/CUT13', 'hex'));
					sprite.antialiasing = true;
					sprite.setGraphicSize(Std.int(sprite.width * 0.8));
					hexDiag = new HEXDialogueBox(false, dialogue, sprite);
			}

			if (hexDiag != null)
			{
				camHUD.visible = false;
				hexDiag.scrollFactor.set();
				hexDiag.finishThing = startCountdown;
			}
		}

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (dad.curCharacter)
		{
			case 'gf':
				if (!stageTesting)
					dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
			case 'senpai':
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				if (FlxG.save.data.distractions)
				{
					// trailArea.scrollFactor.set();
					if (!PlayStateChangeables.Optimize)
					{
						var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
						// evilTrail.changeValuesEnabled(false, false, false, false);
						// evilTrail.changeGraphic()
						add(evilTrail);
					}
					// evilTrail.scrollFactor.set(1.1, 1.1);
				}

				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		if (dad.curCharacter.startsWith("hex"))
			camPos.set(dad.getGraphicMidpoint().x + 145, dad.getGraphicMidpoint().y - 145);

		Stage.update(0);

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		var doof = null;

		if (isStoryMode)
		{
			doof = new DialogueBox(false, dialogue);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;
		}

		if (!isStoryMode && songMultiplier == 1)
		{
			var firstNoteTime = Math.POSITIVE_INFINITY;
			var playerTurn = false;
			for (index => section in SONG.notes)
			{
				if (section.sectionNotes.length > 0 && !isSM)
				{
					if (section.startTime > 5000)
					{
						needSkip = true;
						skipTo = section.startTime - 1000;
					}
					break;
				}
				else if (isSM)
				{
					for (note in section.sectionNotes)
					{
						if (note[0] < firstNoteTime)
						{
							if (!PlayStateChangeables.Optimize)
							{
								firstNoteTime = note[0];
								if (note[1] > 3)
									playerTurn = true;
								else
									playerTurn = false;
							}
							else if (note[1] > 3)
							{
								firstNoteTime = note[0];
							}
						}
					}
					if (index + 1 == SONG.notes.length)
					{
						var timing = ((!playerTurn && !PlayStateChangeables.Optimize) ? firstNoteTime : TimingStruct.getTimeFromBeat(TimingStruct.getBeatFromTime(firstNoteTime)
							- 4));
						if (timing > 5000)
						{
							needSkip = true;
							skipTo = timing - 1000;
						}
					}
				}
			}
		}

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = FlxG.save.data.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		if (!executeModchart)
			if (FlxG.save.data.laneUnderlay && !PlayStateChangeables.Optimize)
			{
				if (!FlxG.save.data.middleScroll)
				{
					add(laneunderlayOpponent);
				}
				add(laneunderlay);
			}

		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StaticArrow>();
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		generateStaticArrows(0);
		generateStaticArrows(1);

		// Update lane underlay positions AFTER static arrows :)

		laneunderlay.x = playerStrums.members[0].x - 25;
		laneunderlayOpponent.x = cpuStrums.members[0].x - 25;

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		// startCountdown();

		if (SONG.songId == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.songId);

		if (Stage.curStage == "hexw" && Paths.doesTextAssetExist('assets/data/songs/${SONG.songId}/${SONG.songId}-reactive.json'))
		{
			// load reactive chart
			reactiveSONG = Song.loadReactive(SONG.songId);
			for (i in reactiveSONG.notes)
			{
				for (note in i.sectionNotes)
				{
					reactiveNotes.push([note[0], note[1], note[2]]);
				}
			}

			Debug.logTrace("Loaded " + reactiveNotes.length + " reactive notes.");
		}
		else
			Debug.logTrace("Not a reactive chart! "
				+ Stage.curStage
				+ ":"
				+ Paths.doesTextAssetExist('assets/data/songs/${SONG.songId}/${SONG.songId}-reactive.json')
				+ ":"
				+ 'assets/data/songs/${SONG.songId}/${SONG.songId}-reactive.json');

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState(isStoryMode);
			luaModchart.executeState('start', [PlayState.SONG.songId]);
		}
		#end

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			new LuaCamera(camGame, "camGame").Register(ModchartState.lua);
			new LuaCamera(camHUD, "camHUD").Register(ModchartState.lua);
			new LuaCamera(camNotes, "camNotes").Register(ModchartState.lua);
			new LuaCharacter(dad, "dad").Register(ModchartState.lua);
			new LuaCharacter(gf, "gf").Register(ModchartState.lua);
			new LuaCharacter(boyfriend, "boyfriend").Register(ModchartState.lua);
		}
		#end

		var index = 0;

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime <= startTime)
					toBeRemoved.push(dunceNote);
			}

			for (i in toBeRemoved)
				unspawnNotes.remove(i);

			Debug.logTrace("Removed " + toBeRemoved.length + " cuz of start time");
		}

		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		if (Stage.curStage == "hexw" || Stage.curStage == "hexwd" || Stage.curStage == "hexwdg")
			camFollow.setPosition(camPos.x, camPos.y + 160);
		else
			camFollow.setPosition(camPos.x, camPos.y);

		if (Stage.curStage == "hexwstage")
			camFollow.setPosition(camPos.x + 135, camPos.y + 15);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = Stage.camZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.loadImage('healthBar', "shared"));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.songName
			+ (FlxMath.roundDecimal(songMultiplier, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songMultiplier, 2) + "x)" : "")
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty),
			16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS,
			(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(accuracy, 0) : accuracy));
		if (!FlxG.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;

		add(scoreTxt);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
		if (FlxG.save.data.judgementCounter)
		{
			add(judgementCounter);
		}

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		replayTxt.cameras = [camHUD];
		if (loadRep)
		{
			add(replayTxt);
		}
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		botPlayState.cameras = [camHUD];
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		addedBotplay = PlayStateChangeables.botPlay;

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(dad.curCharacter, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		if (FlxG.save.data.healthBar)
		{
			add(healthBar);
			add(healthBarBG);
			add(iconP1);
			add(iconP2);

			if (FlxG.save.data.colour)
				healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
			else
				healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		}

		strumLineNotes.cameras = [camNotes];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		laneunderlay.cameras = [camNotes];
		laneunderlayOpponent.cameras = [camNotes];

		if (isStoryMode)
		{
			doof.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];

		if (executeModchart)
		{
			camNotes.zoom = camHUD.zoom;
			camNotes.x = camHUD.x;
			camNotes.y = camHUD.y;
			camNotes.angle = camHUD.angle;
		}

		startingSong = true;

		trace('starting');

		Debug.logTrace(gf);

		dad.dance();
		boyfriend.dance();
		gf.dance();
		if (dark)
			coolingGF.dance();
		if (lcdGF2 != null && lcdGF3 != null)
		{
			lcdGF2.dance();
			lcdGF3.dance();
		}

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: Stage.camZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'dunk' | 'ram' | 'hello-world' | 'glitcher' | 'cooling' | 'detected':
					if (!restartedSong && hexDiag != null)
					{
						hexCutscene(hexDiag);
						if (laneunderlay != null)
						{
							if (laneunderlayOpponent != null)
								laneunderlayOpponent.visible = false;
							laneunderlay.visible = false;
						}
					}
					else
					{
						new FlxTimer().start(1, function(timer)
						{
							startCountdown();
						});
					}
				default:
					new FlxTimer().start(1, function(timer)
					{
						startCountdown();
					});
			}
		}
		else
		{
			new FlxTimer().start(1, function(timer)
			{
				trace('starting');
				startCountdown();
			});
		}

		if (!loadRep)
			rep = new Replay("na");

		// This allow arrow key to be detected by flixel. See https://github.com/HaxeFlixel/flixel/issues/2190
		FlxG.keys.preventDefaultKeys = [];
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
	}

	function lcdSwap(type:Int = 0)
	{
		FlxG.camera.flash(FlxColor.WHITE, 0.6);

		switch (type)
		{
			case 0:
				Stage.swagBacks['lights1'].alpha = 1;
				Stage.swagBacks['lights2'].alpha = 0;
				Stage.swagBacks['lights3'].alpha = 0;
				Stage.swagBacks['crowd1'].alpha = 1;
				Stage.swagBacks['crowd2'].alpha = 0;
				Stage.swagBacks['crowd3'].alpha = 0;
				Stage.swagBacks['hexBack1'].alpha = 1;
				Stage.swagBacks['hexBack2'].alpha = 0;
				Stage.swagBacks['hexBack3'].alpha = 0;
				Stage.swagBacks['hexFront1'].alpha = 1;
				Stage.swagBacks['hexFront2'].alpha = 0;
				Stage.swagBacks['hexFront3'].alpha = 0;
				lcdDad2.alpha = 0;
				lcdDad3.alpha = 0;
				lcdBF2.alpha = 0;
				lcdBF3.alpha = 0;
				lcdGF2.alpha = 0;
				lcdGF3.alpha = 0;
				dad.alpha = 1;
				boyfriend.alpha = 1;
				gf.alpha = 1;
			case 1:
				Stage.swagBacks['lights1'].alpha = 0;
				Stage.swagBacks['lights2'].alpha = 1;
				Stage.swagBacks['lights3'].alpha = 0;
				Stage.swagBacks['crowd1'].alpha = 0;
				Stage.swagBacks['crowd2'].alpha = 1;
				Stage.swagBacks['crowd3'].alpha = 0;
				Stage.swagBacks['hexBack1'].alpha = 0;
				Stage.swagBacks['hexBack2'].alpha = 1;
				Stage.swagBacks['hexBack3'].alpha = 0;
				Stage.swagBacks['hexFront1'].alpha = 0;
				Stage.swagBacks['hexFront2'].alpha = 1;
				Stage.swagBacks['hexFront3'].alpha = 0;
				lcdDad2.alpha = 1;
				lcdDad3.alpha = 0;
				lcdBF2.alpha = 1;
				lcdBF3.alpha = 0;
				lcdGF2.alpha = 1;
				lcdGF3.alpha = 0;
				dad.alpha = 0;
				boyfriend.alpha = 0;
				gf.alpha = 0;
			case 2:
				Stage.swagBacks['lights1'].alpha = 0;
				Stage.swagBacks['lights2'].alpha = 0;
				Stage.swagBacks['lights3'].alpha = 1;
				Stage.swagBacks['crowd1'].alpha = 0;
				Stage.swagBacks['crowd2'].alpha = 0;
				Stage.swagBacks['crowd3'].alpha = 1;
				Stage.swagBacks['hexBack1'].alpha = 0;
				Stage.swagBacks['hexBack2'].alpha = 0;
				Stage.swagBacks['hexBack3'].alpha = 1;
				Stage.swagBacks['hexFront1'].alpha = 0;
				Stage.swagBacks['hexFront2'].alpha = 0;
				Stage.swagBacks['hexFront3'].alpha = 1;

				lcdDad2.alpha = 0;
				lcdDad3.alpha = 1;
				lcdBF2.alpha = 0;
				lcdBF3.alpha = 1;
				lcdGF2.alpha = 0;
				lcdGF3.alpha = 1;
				dad.alpha = 0;
				boyfriend.alpha = 0;
				gf.alpha = 0;
		}
	}

	function hexCutscene(diag:HEXDialogueBox)
	{
		inCutscene = true;
		add(diag);
	}

	var lastUpdatedSectionId = 0;

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (PlayState.SONG.songId == 'roses' || PlayState.SONG.songId == 'thorns')
		{
			remove(black);

			if (PlayState.SONG.songId == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (PlayState.SONG.songId == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];

	#if FEATURE_LUAMODCHART
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		Debug.logTrace("start count");
		inCutscene = false;

		for (i in FlxG.sound.list)
			i.stop();

		Debug.logTrace("appear");

		appearStaticArrows();
		// generateStaticArrows(0);
		// generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		startingSong = true;
		camHUD.visible = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		if (FlxG.sound.music.playing)
			FlxG.sound.music.stop();
		if (vocals != null)
			vocals.stop();

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			// this just based on beatHit stuff but compact
			if (allowedToHeadbang && swagCounter % gfSpeed == 0)
			{
				gf.dance();
				if (dark)
					coolingGF.dance();
				if (lcdGF2 != null && lcdGF3 != null)
				{
					lcdGF2.dance();
					lcdGF3.dance();
				}
			}
			if (swagCounter % idleBeat == 0)
			{
				if (idleToBeat && !boyfriend.animation.curAnim.name.endsWith("miss"))
					boyfriend.dance(forcedToIdle);
				if (idleToBeat)
					dad.dance(forcedToIdle);
			}
			else if (dad.curCharacter == 'spooky' || dad.curCharacter == 'gf')
				dad.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var week6Bullshit:String = "shared";

			if (SONG.noteStyle == 'pixel')
			{
				introAlts = introAssets.get('pixel');
				altSuffix = '-pixel';
				week6Bullshit = 'week6';
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix, "shared"), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[0], week6Bullshit));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (SONG.noteStyle == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * CoolUtil.daPixelZoom));

					ready.screenCenter();
					Debug.logTrace("addi");
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix, "shared"), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[1], week6Bullshit));
					set.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						set.setGraphicSize(Std.int(set.width * CoolUtil.daPixelZoom));

					set.screenCenter();
					Debug.logTrace("addi");
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix, "shared"), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[2], week6Bullshit));
					go.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						go.setGraphicSize(Std.int(go.width * CoolUtil.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					Debug.logTrace("addi");
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix, "shared"), 0.6);
			}

			swagCounter += 1;
		}, 4);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	public function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	public var closestNotes:Array<Note> = [];

	public function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		closestNotes = [];

		if (notes == null)
			return;

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && daNote.visible && !daNote.wasGoodHit)
				closestNotes.push(daNote);
		}); // Collect notes that can be hit

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		for (i in closestNotes)
			if (i.noteData == data && !i.isSustainNote)
				dataNotes.push(i);

		trace("notes able to hit for " + key.toString() + " " + dataNotes.length);

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
			{
				coolNote = i;
				break;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						note.alive = false;
						note.alpha = 0;
						notes.remove(note, true);
						note.destroy();
						/*if (executeModchart)
							ModchartState.shownNotes.remove(note.LuaNote); */
					}
				}
			}

			boyfriend.holdTimer = 0;
			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.judgeNote(noteDiff);
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.20;
		}
	}

	public var songStarted = false;

	public var doAnything = false;

	public static var songMultiplier = 1.0;

	public var bar:FlxSprite;

	public var previousRate = songMultiplier;

	public var coolingHandler:MP4Handler = null;

	function startSong():Void
	{
		if (laneunderlay != null)
		{
			if (laneunderlayOpponent != null)
				laneunderlayOpponent.visible = true;
			laneunderlay.visible = true;
		}
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.music.play();
		vocals.play();

		// have them all dance when the song starts
		if (allowedToHeadbang)
			gf.dance();
		if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.dance(forcedToIdle);
		if (idleToBeat && !dad.animation.curAnim.name.startsWith("sing"))
			dad.dance(forcedToIdle);

		// Song check real quick
		switch (curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog':
				allowedToCheer = true;
			default:
				allowedToCheer = false;
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart)
			luaModchart.executeState("songStart", [null]);
		#end

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		/*@:privateAccess
			{
				var aux = AL.createAux();
				var fx = AL.createEffect();
				AL.effectf(fx,AL.PITCH,songMultiplier);
				AL.auxi(aux, AL.EFFECTSLOT_EFFECT, fx);
				var instSource = FlxG.sound.music._channel.__source;

				var backend:lime._internal.backend.native.NativeAudioSource = instSource.__backend;

				AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				if (vocals != null)
				{
					var vocalSource = vocals._channel.__source;

					backend = vocalSource.__backend;
					AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				}

				trace("pitched to " + songMultiplier);
		}*/

		#if cpp
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		trace("pitched inst and vocals to " + songMultiplier);
		#end

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(healthBarBG.x + 80, healthBarBG.y - 110, 500);
			skipText.text = "Press Space to Skip Intro";
			skipText.size = 30;
			skipText.color = FlxColor.WHITE;
			skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			skipText.cameras = [camHUD];
			skipText.alpha = 0;
			FlxTween.tween(skipText, {alpha: 1}, 0.2);
			add(skipText);
		}

		if (Stage.curStage == "hexw" && SONG.songId.toLowerCase() == "cooling")
		{
			var perecentSupposed = (FlxG.sound.music.time / songMultiplier) / (FlxG.sound.music.length / songMultiplier);
			coolingHandler.bitmap.seek(perecentSupposed); // I laughed my ass off so hard when I found out this was a fuckin PERCENTAGE
			Debug.logTrace("doing the thing");
			FlxTween.tween(coolingVideo, {alpha: 1}, 1);
		}
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.songId;

		#if FEATURE_STEPMANIA
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			#if FEATURE_STEPMANIA
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#end
		}

		FlxG.sound.music.pause();

		if (SONG.needsVoices && !PlayState.isSM)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.songId));
		if (!PlayState.isSM)
			FlxG.sound.cache(Paths.inst(PlayState.SONG.songId));

		// Song duration in a float, useful for the time left feature
		songLength = ((FlxG.sound.music.length / songMultiplier) / 1000);

		Conductor.crochet = ((60 / (SONG.bpm) * 1000));
		Conductor.stepCrochet = Conductor.crochet / 4;

		if (FlxG.save.data.songPosition)
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.loadImage('healthBar', "shared"));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 35;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();

			songPosBar = new FlxBar(640 - (Std.int(songPosBG.width - 100) / 2), songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 100),
				Std.int(songPosBG.height + 6), this, 'songPositionBar', 0, songLength);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.fromRGB(0, 255, 128));
			add(songPosBar);

			bar = new FlxSprite(songPosBar.x, songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);

			add(bar);

			FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT, {thickness: 4, color: FlxColor.BLACK});

			songPosBG.width = songPosBar.width;

			songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.songName.length * 5), songPosBG.y - 15, 0, SONG.songName, 16);
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();

			songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime(songLength, false) + ')';
			songName.y = songPosBG.y + (songPosBG.height / 3);

			add(songName);

			songName.screenCenter(X);

			songPosBG.cameras = [camHUD];
			bar.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] / songMultiplier;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var rawData:Int = songNotes[1];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = true;

				if (songNotes[1] > 3 && section.mustHitSection)
					gottaHitNote = false;
				else if (songNotes[1] < 4 && !section.mustHitSection)
					gottaHitNote = false;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, false, songNotes[4]);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.rawNoteData = rawData;

				swagNote.sustainLength = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(songNotes[2] / songMultiplier)));
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				swagNote.isAlt = songNotes[3]
					|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
					|| (section.playerAltAnim && gottaHitNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					sustainNote.isAlt = songNotes[3]
						|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
						|| (section.playerAltAnim && gottaHitNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;

		Debug.logTrace("whats the fuckin shit");
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StaticArrow = new StaticArrow(-10, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			if (SONG.noteStyle == null && FlxG.save.data.overrideNoteskins)
			{
				switch (storyWeek)
				{
					case 6:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(noteskinPixelSprite, true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * CoolUtil.daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.add('static', [i]);
					babyArrow.animation.add('pressed', [4 + i, 8 + i], 12, false);
					babyArrow.animation.add('confirm', [12 + i, 16 + i], 24, false);

					for (j in 0...4)
					{
						babyArrow.animation.add('dirCon' + j, [12 + j, 16 + j], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas("noteskins/Arrows", "shared");
					// Debug.logTrace(babyArrow.frames);
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);
						babyArrow.animation.addByPrefix('dirCon' + j, dataSuffix[j].toLowerCase() + ' confirm', 24, false);
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				// babyArrow.alpha = 0;
				if (!FlxG.save.data.middleScroll || executeModchart || player == 1)
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					babyArrow.x += 20;
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 110;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize || (FlxG.save.data.middleScroll && !executeModchart))
				babyArrow.x -= 320;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		Debug.logTrace("appearing");
		var index = 0;
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode && !FlxG.save.data.middleScroll || executeModchart)
				babyArrow.alpha = 1;
			if (index > 3 && FlxG.save.data.middleScroll)
				babyArrow.alpha = 1;
			index++;
		});
		Debug.logTrace("appeared");
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
				if (vocals != null)
					if (vocals.playing)
						vocals.pause();
			}

			if (Stage.curStage == "hexw" && songStarted && SONG.songId.toLowerCase() == "cooling")
			{
				coolingHandler.bitmap.pause();
			}

			#if FEATURE_DISCORD
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (startTimer != null)
				if (!startTimer.finished)
					startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (PauseSubState.goToOptions)
		{
			Debug.logTrace("pause thingyt");
			if (PauseSubState.goBack)
			{
				Debug.logTrace("pause thingyt");
				PauseSubState.goToOptions = false;
				PauseSubState.goBack = false;
				openSubState(new PauseSubState());
			}
			else
				openSubState(new OptionsMenu(true));
		}
		else if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (Stage.curStage == "hexw" && songStarted && SONG.songId.toLowerCase() == "cooling")
			{
				var perecentSupposed = (FlxG.sound.music.time / songMultiplier) / (FlxG.sound.music.length / songMultiplier);
				coolingHandler.bitmap.seek(perecentSupposed); // I laughed my ass off so hard when I found out this was a fuckin PERCENTAGE
				coolingHandler.bitmap.resume();
			}

			if (startTimer != null)
				if (!startTimer.finished)
					startTimer.active = true;
			paused = false;

			#if FEATURE_DISCORD
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.songName + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}
		else
		{
			persistentUpdate = true;
			persistentDraw = true;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		if (endingSong)
			return;
		vocals.stop();
		FlxG.sound.music.stop();

		FlxG.sound.music.play();
		vocals.play();
		FlxG.sound.music.time = Conductor.songPosition * songMultiplier;
		vocals.time = FlxG.sound.music.time;
		@:privateAccess
		{
			#if desktop
			// The __backend.handle attribute is only available on native.
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			#end
		}

		#if FEATURE_DISCORD
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	public var pastScrollChanges:Array<Song.Event> = [];

	public var currentLuaIndex = 0;

	var activeTweens:Array<Array<FlxTween>> = [[], [], [], []];

	override public function update(elapsed:Float)
	{
		if (!loadedCompletely)
			return;

		var rtemove = [];

		for (i in FlxG.cameras.list)
		{
			if (i.flashSprite == null)
			{
				Debug.logError("FUCK A CAMERA'S FLASH SPRITE WAS NULL, GOTTA REMOVE IT.");
				rtemove.push(i);
			}
		}

		for (i in rtemove)
			FlxG.cameras.remove(i);

		#if !debug
		perfectMode = false;
		#end
		if (!PlayStateChangeables.Optimize)
			Stage.update(elapsed);

		if (!addedBotplay && FlxG.save.data.botplay)
		{
			PlayStateChangeables.botPlay = true;
			addedBotplay = true;
			add(botPlayState);
		};

		if (Stage.curStage == "hexw" && reactiveNotes.length != 0)
		{
			var reactive = reactiveNotes[0];
			var nextReact = reactiveNotes[1];

			var index:Int = reactiveNotes.indexOf(reactive);

			var space:Float = 0.4;

			if (nextReact != null)
			{
				var diff = nextReact[0] - reactive[0];
				if (diff <= 100)
					space = (diff / 0.5) / 1000;
			}

			if (space <= 0)
				space = 0.4;
			if (reactive[0] <= Conductor.songPosition)
			{
				Debug.logTrace("doing spotlight " + reactive[1] + " with time of " + reactive[2] + " space " + space);
				if (activeTweens[reactive[1]][0] != null)
				{
					activeTweens[reactive[1]][0].cancel();
					activeTweens[reactive[1]].remove(activeTweens[reactive[1]][0]);
				}

				Stage.swagBacks['spot' + reactive[1]].alpha = 0.8;
				activeTweens[reactive[1]].push(FlxTween.tween(Stage.swagBacks['spot' + reactive[1]], {alpha: 0}, space, {
					onComplete: function(tw)
					{
						activeTweens[reactive[1]].remove(activeTweens[reactive[1]][0]);
					}
				}));

				reactiveNotes.splice(index, 1);
			}
		}

		if (unspawnNotes[0] != null)
		{
			FlxG.watch.addQuick("beat shitt", TimingStruct.getBeatFromTime(unspawnNotes[0].strumTime) - curDecimalBeat);
			if (TimingStruct.getBeatFromTime(unspawnNotes[0].strumTime) - curDecimalBeat <= beatCutoff)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				#if FEATURE_LUAMODCHART
				if (executeModchart)
				{
					currentLuaIndex++;
					var n = new LuaNote(dunceNote, currentLuaIndex);
					n.Register(ModchartState.lua);
					ModchartState.shownNotes.push(n);
					dunceNote.LuaNote = n;
					dunceNote.luaID = currentLuaIndex;
				}
				#end
				if (executeModchart)
				{
					#if FEATURE_LUAMODCHART
					dunceNote.cameras = [camNotes];
					#end
				}
				else
				{
					dunceNote.cameras = [camHUD];
				}
				var index:Int = unspawnNotes.indexOf(dunceNote);

				unspawnNotes.splice(index, 1);
				currentLuaIndex++;
			}
		}
		#if cpp
		if (FlxG.sound.music.playing)
			@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		#end
		if (generatedMusic)
		{
			if (songStarted && !endingSong)
			{
				// Song ends abruptly on slow rate even with second condition being deleted,
				// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
				// so no reason to delete it at all
				if (unspawnNotes.length == 0 && notes.length == 0 && FlxG.sound.music.time > FlxG.sound.music.length - 100)
				{
					Debug.logTrace("we're fuckin ending the song ");
					endingSong = true;
					new FlxTimer().start(2, function(timer)
					{
						endSong();
					});
				}
			}
		}
		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();
			var currentIndex = 0;
			for (i in SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;
					var endBeat:Float = Math.POSITIVE_INFINITY;
					var bpm = i.value * songMultiplier;
					TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset
					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
					}
					currentIndex++;
				}
			}
			updateFrame++;
		}
		else if (updateFrame != 5)
			updateFrame++;
		if (FlxG.sound.music.playing)
		{
			var timingSeg = TimingStruct.getTimingAtBeat(curDecimalBeat);
			if (timingSeg != null)
			{
				var timingSegBpm = timingSeg.bpm;
				if (timingSegBpm != Conductor.bpm)
				{
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
					Conductor.crochet = ((60 / (timingSegBpm) * 1000)) / songMultiplier;
					Conductor.stepCrochet = Conductor.crochet / 4;
				}
			}
			var newScroll = 1.0;
			for (i in SONG.eventObjects)
			{
				switch (i.type)
				{
					case "Scroll Speed Change":
						if (i.position <= curDecimalBeat && !pastScrollChanges.contains(i))
						{
							pastScrollChanges.push(i);
							trace("SCROLL SPEED CHANGE to " + i.value);
							newScroll = i.value;
						}
				}
			}
			if (newScroll != 0)
				PlayStateChangeables.scrollSpeed *= newScroll;
		}
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;
		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				removedVideo = true;
			}
		}
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat, 3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);
			for (key => value in luaModchart.luaWiggles)
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}
			PlayStateChangeables.useDownscroll = luaModchart.getVar("downscroll", "bool");
			PlayStateChangeables.scrollSpeed = luaModchart.getVar("scrollSpeed", "float");
			beatCutoff = luaModchart.getVar("beatcutoff", "float");
			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/
			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');
			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}
			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');
			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end
		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}
		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();
		scoreTxt.screenCenter(X);
		var pauseBind = FlxKey.fromString(FlxG.save.data.pauseBind);
		var gppauseBind = FlxKey.fromString(FlxG.save.data.gppauseBind);
		if ((FlxG.keys.anyJustPressed([pauseBind])) && startedCountdown && canPause && !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			openSubState(new PauseSubState());
		}
		if (FlxG.keys.justPressed.FIVE && songStarted)
		{
			songMultiplier = 1;
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				removedVideo = true;
			}
			cannotDie = true;
			// switchState(new WaveformTestState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		if (FlxG.keys.justPressed.SEVEN && songStarted)
		{
			songMultiplier = 1;
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				removedVideo = true;
			}
			cannotDie = true;
			switchState(new ChartingState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);

		if (lerp > 0)
			lerp -= 1 * (elapsed * 1.04) + (SONG.bpm / 1000);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width * 1.04, lerp)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width * 1.04, lerp)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;
		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;
		/* if (FlxG.keys.justPressed.NINE)
			switchState(new Charting()); */
		if (FlxG.keys.justPressed.SIX)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				removedVideo = true;
			}
			switchState(new AnimationDebug(dad.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		if (!PlayStateChangeables.Optimize)
			if (FlxG.keys.justPressed.EIGHT && songStarted)
			{
				paused = true;
				if (useVideo)
				{
					GlobalVideo.get().stop();
					remove(videoSprite);
					removedVideo = true;
				}
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					for (bg in Stage.toAdd)
					{
						remove(bg);
					}
					for (bg in Stage.appearInFront)
					{
						remove(bg);
					}
					for (array in Stage.layInFront)
					{
						for (bg in array)
							remove(bg);
					}
					for (group in Stage.swagGroup)
					{
						remove(group);
					}
					remove(boyfriend);
					remove(dad);
					remove(gf);
				});

				// switchState(new StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter, dad.curCharacter));
				clean();
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end
			}
		if (FlxG.keys.justPressed.ZERO)
		{
			switchState(new AnimationDebug(boyfriend.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		if (skipActive && Conductor.songPosition >= skipTo)
		{
			remove(skipText);
			skipActive = false;
		}
		if (FlxG.keys.justPressed.SPACE && skipActive)
		{
			var rremove:Array<Array<Dynamic>> = [];
			for (i in reactiveNotes)
			{
				if (i[0] < skipTo)
					rremove.push(i);
			}
			for (i in rremove)
			{
				reactiveNotes.remove(i);
			}
			rremove = [];
			FlxG.sound.music.pause();
			vocals.pause();
			Conductor.songPosition = skipTo;
			Conductor.rawPosition = skipTo;
			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();
			vocals.time = Conductor.songPosition;
			vocals.play();
			FlxTween.tween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
		}
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = Conductor.songPosition;

				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			Conductor.rawPosition = FlxG.sound.music.time;
			if (coolingVideo != null)
			{
				if (!coolingHandler.bitmap.isPlaying && !paused && !endingSong)
					coolingHandler.bitmap.resume();
			}
			// sync
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = (Conductor.songPosition - songLength) / 1000;
			currentSection = getSectionByTime(Conductor.songPosition);
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;
				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
				var curTime:Float = FlxG.sound.music.time / songMultiplier;
				if (curTime < 0)
					curTime = 0;
				var secondsTotal:Int = Math.floor(((curTime - songLength) / 1000));
				if (secondsTotal < 0)
					secondsTotal = 0;
				if (FlxG.save.data.songPosition)
					songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime((songLength - secondsTotal), false) + ')';
			}
			// Conductor.lastSongPos = FlxG.sound.music.time;
		}
		if (generatedMusic && currentSection != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToCheer)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Philly Nice':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'Blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.setVar("mustHit", currentSection.mustHitSection);
			#end
			if (camFollow.x != dad.getMidpoint().x + 150
				&& !currentSection.mustHitSection
				&& Math.floor(currentSection.startTime) != lastUpdatedSectionId)
			{
				lastUpdatedSectionId = Math.floor(currentSection.startTime);
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				if (Stage.curStage == "hexw" || Stage.curStage == "hexwd" || Stage.curStage == "hexwdg" || Stage.curStage == "hexwstage")
				{
					offsetY = -25;
					offsetX = 0;
				}
				if (SONG.song.toLowerCase() == "cooling")
				{
					if (dark && Stage.curStage == "hexw")
					{
						var spot = Stage.swagBacks['breakSpot0'];
						var ospot = Stage.swagBacks['breakSpot1'];
						spot.x = dad.x - 25;
						spot.y = -dad.y - 160;
						FlxTween.tween(spot, {alpha: 1}, 0.45);
						FlxTween.tween(ospot, {alpha: 0}, 0.45);
					}
					else if (Stage.curStage == "hexw")
					{
						var spot = Stage.swagBacks['breakSpot1'];
						var ospot = Stage.swagBacks['breakSpot0'];
						if (spot.alpha != 0 || ospot.alpha != 0)
						{
							FlxTween.tween(spot, {alpha: 0}, 0.45);
							FlxTween.tween(ospot, {alpha: 0}, 0.45);
						}
					}
				}
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - (100 + offsetY));
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);
				switch (dad.curCharacter)
				{
					case 'mom' | 'mom-car':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai' | 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}
			}
			if (currentSection.mustHitSection
				&& camFollow.x != boyfriend.getMidpoint().x - 100
				&& Math.floor(currentSection.startTime) != lastUpdatedSectionId)
			{
				lastUpdatedSectionId = Math.floor(currentSection.startTime);
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				if (Stage.curStage == "hexw" || Stage.curStage == "hexwd" || Stage.curStage == "hexwdg" || Stage.curStage == "hexwstage")
				{
					offsetY = 20;
					offsetX = 68;
				}
				if (SONG.song.toLowerCase() == "cooling")
				{
					if (dark && Stage.curStage == "hexw")
					{
						var spot = Stage.swagBacks['breakSpot1'];
						var ospot = Stage.swagBacks['breakSpot0'];
						spot.x = boyfriend.x - 24;
						spot.y = -boyfriend.y + 140;
						FlxTween.tween(spot, {alpha: 1}, 0.45);
						FlxTween.tween(ospot, {alpha: 0}, 0.45);
					}
					else if (Stage.curStage == "hexw")
					{
						var spot = Stage.swagBacks['breakSpot1'];
						var ospot = Stage.swagBacks['breakSpot0'];
						if (spot.alpha != 0 || ospot.alpha != 0)
						{
							FlxTween.tween(spot, {alpha: 0}, 0.45);
							FlxTween.tween(ospot, {alpha: 0}, 0.45);
						}
					}
				}
				camFollow.setPosition(boyfriend.getMidpoint().x - (100 + offsetX), boyfriend.getMidpoint().y - (100 + offsetY));
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end
				if (!PlayStateChangeables.Optimize)
					switch (Stage.curStage)
					{
						case 'limo':
							camFollow.x = boyfriend.getMidpoint().x - 300;
						case 'mall':
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'school':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'schoolEvil':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;
					}
			}
		}
		if (camZooming)
		{
			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;
			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;
			if (!executeModchart)
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);
				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
			else
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
		}
		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// switchState(new TitleState());
			}
		}
		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel)
			{
				boyfriend.stunned = true;
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
				vocals.stop();
				FlxG.sound.music.stop();
				if (FlxG.save.data.InstantRespawn)
				{
					switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end
				// God i love futabu!! so fucking much (From: McChomk)
				// switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			var resetBind = FlxKey.fromString(FlxG.save.data.resetBind);
			var gpresetBind = FlxKey.fromString(FlxG.save.data.gpresetBind);
			if (FlxG.keys.anyJustPressed([resetBind]))
			{
				boyfriend.stunned = true;
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
				vocals.stop();
				FlxG.sound.music.stop();
				if (FlxG.save.data.InstantRespawn)
				{
					restart();
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end
				// switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}
		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (executeModchart)
				{
					if (lScrl[daNote.rawNoteData] < 0)
					{
						if (daNote.children.length > 0)
						{
							daNote.children[daNote.children.length - 1].flipY = true;
						}
					}
					else
					{
						if (daNote.children.length > 0)
						{
							daNote.children[daNote.children.length - 1].flipY = false;
						}
					}
				}
				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								- daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								- daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height;
							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (lScrl[daNote.rawNoteData] == 1 ? SONG.speed : lScrl[daNote.rawNoteData]))
								+ daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (lScrl[daNote.rawNoteData] == 1 ? SONG.speed : lScrl[daNote.rawNoteData]))
								+ daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							if (executeModchart)
							{
								if (lScrl[daNote.rawNoteData] < 0)
								{
									daNote.y -= daNote.height - daNote.stepHeight;
								}
							}
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}
						}
					}
				}
				if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime && daNote.visible)
				{
					if (SONG.songId != 'tutorial')
						camZooming = true;
					var altAnim:String = "";
					if (daNote.isAlt)
					{
						altAnim = '-alt';
						trace("YOO WTF THIS IS AN ALT NOTE????");
					}
					// Accessing the animation name directly to play it
					if (!daNote.isParent && daNote.parent != null)
					{
						if (daNote.spotInLine != daNote.parent.children.length - 1)
						{
							var singData:Int = Std.int(Math.abs(daNote.noteData));
							dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							if (glitched)
								glitcherDad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							if (glitcherRDad != null)
								glitcherRDad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							if (dark)
								coolingDad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							if (lcdDad2 != null && lcdDad3 != null)
							{
								lcdDad2.playAnim('sing' + dataSuffix[singData] + altAnim, true);
								lcdDad3.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							}
							if (FlxG.save.data.cpuStrums)
							{
								cpuStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
									/*
										if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
										{
											spr.centerOffsets();
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										}
										else
											spr.centerOffsets();
									 */
								});
							}
							#if FEATURE_LUAMODCHART
							if (luaModchart != null)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							#end
							dad.holdTimer = 0;
							if (glitched)
								glitcherDad.holdTimer = 0;
							if (glitcherRDad != null)
								glitcherRDad.holdTimer = 0;
							if (dark)
								coolingDad.holdTimer = 0;
							if (lcdDad2 != null && lcdDad3 != null)
							{
								lcdDad2.holdTimer = 0;
								lcdDad3.holdTimer = 0;
							}
							if (SONG.needsVoices)
								vocals.volume = 1;
						}
					}
					else
					{
						var singData:Int = Std.int(Math.abs(daNote.noteData));
						dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
						if (glitched)
							glitcherDad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
						if (glitcherRDad != null)
							glitcherRDad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
						if (dark)
							coolingDad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
						if (lcdDad2 != null && lcdDad3 != null)
						{
							lcdDad2.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							lcdDad3.playAnim('sing' + dataSuffix[singData] + altAnim, true);
						}
						if (FlxG.save.data.cpuStrums)
						{
							cpuStrums.forEach(function(spr:StaticArrow)
							{
								pressArrow(spr, spr.ID, daNote);
								/*
									if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								 */
							});
						}
						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end
						dad.holdTimer = 0;
						if (glitched)
							glitcherDad.holdTimer = 0;
						if (glitcherRDad != null)
							glitcherRDad.holdTimer = 0;
						if (dark)
							coolingDad.holdTimer = 0;
						if (lcdDad2 != null && lcdDad3 != null)
						{
							lcdDad2.holdTimer = 0;
							lcdDad3.holdTimer = 0;
						}
						if (SONG.needsVoices)
							vocals.volume = 1;
					}
					if (Stage.curStage == "hexw" && doMoveArrows)
					{
						var offsetxx = 0;
						var offsetyy = 0;
						switch (daNote.noteData)
						{
							case 0:
								offsetxx = -24;
							case 1:
								offsetyy = 24;
							case 2:
								offsetyy = -24;
							case 3:
								offsetxx = 24;
						}
						camFollow.setPosition((dad.getMidpoint().x + 150) + offsetxx, (dad.getMidpoint().y - 50) + offsetyy);
					}
					daNote.visible = false;
					/*if (executeModchart)
						ModchartState.shownNotes.remove(daNote.LuaNote); */
				}
				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					// daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					// daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
				}

				if (!daNote.mustPress && FlxG.save.data.middleScroll && !executeModchart)
					daNote.alpha = 0;
				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (SONG.noteStyle == 'pixel')
						daNote.x -= 11;
				}
				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					daNote.visible = false;
					/*if (executeModchart)
						ModchartState.shownNotes.remove(daNote.LuaNote); */
				}

				var diff = (daNote.strumTime / songMultiplier) - (Conductor.songPosition / songMultiplier);

				var window = -((Ratings.timingWindows[0]) * Conductor.timeScale);

				if (diff < window && songStarted)
				{
					if (!daNote.mustPress)
					{
						daNote.kill();
						daNote.alive = false;
						notes.remove(daNote, true);
						daNote.destroy();
					}
					else
					{
						if (daNote.visible)
						{
							if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
							}
							else
							{
								if (loadRep && daNote.isSustainNote)
								{
									// im tired and lazy this sucks I know i'm dumb
									if (findByTime(daNote.strumTime) != null)
										totalNotesHit += 1;
									else
									{
										vocals.volume = 0;
										if (theFunne && !daNote.isSustainNote)
										{
											noteMiss(daNote.noteData, daNote);
										}
										if (daNote.isParent)
										{
											health -= 0.15; // give a health punishment for failing a LN
											trace("hold fell over at the start");
											for (i in daNote.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
										}
										else
										{
											if (!daNote.wasGoodHit
												&& daNote.isSustainNote
												&& daNote.sustainActive
												&& daNote.spotInLine != daNote.parent.children.length)
											{
												// health -= 0.05; // give a health punishment for failing a LN
												trace("hold fell over at " + daNote.spotInLine);
												for (i in daNote.parent.children)
												{
													i.alpha = 0.3;
													i.sustainActive = false;
												}
												if (daNote.parent.wasGoodHit)
												{
													misses++;
													totalNotesHit -= 1;
												}
												updateAccuracy();
											}
											else if (!daNote.wasGoodHit && !daNote.isSustainNote)
											{
												misses++;
												updateAccuracy();
												health -= 0.15;
											}
										}
									}
								}
								else
								{
									vocals.volume = 0;
									if (theFunne && !daNote.isSustainNote)
									{
										if (PlayStateChangeables.botPlay)
										{
											daNote.rating = "bad";
											goodNoteHit(daNote);
										}
										else
											noteMiss(daNote.noteData, daNote);
									}
									if (daNote.isParent && daNote.visible)
									{
										health -= 0.15; // give a health punishment for failing a LN
										trace("hold fell over at the start");
										for (i in daNote.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
									}
									else
									{
										if (!daNote.wasGoodHit
											&& daNote.isSustainNote
											&& daNote.sustainActive
											&& daNote.spotInLine != daNote.parent.children.length)
										{
											// health -= 0.05; // give a health punishment for failing a LN
											trace("hold fell over at " + daNote.spotInLine);
											for (i in daNote.parent.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
											if (daNote.parent.wasGoodHit)
											{
												misses++;
												totalNotesHit -= 1;
											}
											updateAccuracy();
										}
										else if (!daNote.wasGoodHit && !daNote.isSustainNote)
										{
											misses++;
											updateAccuracy();
											health -= 0.15;
										}
									}
								}
							}
							daNote.visible = false;
							daNote.kill();
							notes.remove(daNote, true);
						}
						else
						{
							daNote.kill();
							notes.remove(daNote, true);
						}
					}
				}
			});
		}
		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:StaticArrow)
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static');
					spr.centerOffsets();
				}
			});
		}
		if (!inCutscene && songStarted)
			keyShit();
		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
		super.update(elapsed);
	}

	public function getSectionByTime(ms:Float):SwagSection
	{
		for (i in SONG.notes)
		{
			var start = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.startTime)));
			var end = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.endTime)));

			if (ms >= start && ms < end)
			{
				return i;
			}
		}

		return null;
	}

	function recalculateAllSectionTimes()
	{
		trace("RECALCULATING SECTION TIMES");

		for (i in 0...SONG.notes.length) // loops through sections
		{
			var section = SONG.notes[i];

			var currentBeat = 4 * i;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				return;

			var start:Float = (currentBeat - currentSeg.startBeat) / ((currentSeg.bpm) / 60);

			section.startTime = (currentSeg.startTime + start) * 1000;

			if (i != 0)
				SONG.notes[i - 1].endTime = section.startTime;
			section.endTime = Math.POSITIVE_INFINITY;
		}
	}

	function endSong():Void
	{
		endingSong = true;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		if (useVideo)
		{
			GlobalVideo.get().stop();
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1 / songMultiplier;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.stop();
		vocals.stop();
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}
		var isDetected = SONG.songId == "detected";
		var isGlitcher = SONG.songId == "glitcher";
		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			clean();
			FlxG.save.data.offset = offsetTest;
		}
		else if (stageTesting)
		{
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				for (bg in Stage.toAdd)
				{
					remove(bg);
				}
				for (bg in Stage.appearInFront)
				{
					remove(bg);
				}
				for (array in Stage.layInFront)
				{
					for (bg in array)
						remove(bg);
				}
				remove(boyfriend);
				remove(dad);
				remove(gf);
			});
			// switchState(new StageDebugState(Stage.curStage));
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);
				campaignMisses += misses;
				campaignSicks += sicks;
				campaignGoods += goods;
				campaignBads += bads;
				campaignShits += shits;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					if (isGlitcher)
					{
						FlxG.save.data.weekxBeat = true;
						var state = new UnlockedState();
						state.unlockSprite = "unlock_screen_1";
						switchState(state);
					}
					else if (isDetected)
					{
						FlxG.save.data.weekendxBeat = true;
						FlxG.camera.zoom = 1;
						switchState(new BruhADiagWindow("detectedEnd"));
					}
					else
					{
						if (FlxG.save.data.scoreScreen)
						{
							if (FlxG.save.data.songPosition)
							{
								FlxTween.tween(songPosBar, {alpha: 0}, 1);
								FlxTween.tween(bar, {alpha: 0}, 1);
								FlxTween.tween(songName, {alpha: 0}, 1);
							}
							openSubState(new ResultsScreen());
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});
						}
						else
						{
							GameplayCustomizeState.freeplayBf = 'bf';
							GameplayCustomizeState.freeplayDad = 'dad';
							GameplayCustomizeState.freeplayGf = 'gf';
							GameplayCustomizeState.freeplayNoteStyle = 'normal';
							GameplayCustomizeState.freeplayStage = 'stage';
							GameplayCustomizeState.freeplaySong = 'bopeebo';
							GameplayCustomizeState.freeplayWeek = 1;
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							Conductor.changeBPM(102);
							switchState(new HexStoryMenu(HexMenuState.loadHexMenu("story-menu")));
							clean();
						}
					}

					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					// StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					var diff:String = ["-easy", "", "-hard", "-funky"][storyDifficulty];

					Debug.logInfo('PlayState: Loading next story song ${PlayState.storyPlaylist[0]}-${diff}');

					if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					var isCooling = SONG.songId == "cooling";

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], diff);
					FlxG.sound.music.stop();

					if (isCooling)
					{
						switchState(new StoryScene("animated_cutscene"));
					}
					else
					{
						switchState(new PlayState());
						clean();
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (FlxG.save.data.scoreScreen)
				{
					openSubState(new ResultsScreen());
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						inResults = true;
					});
				}
				else
				{
					for (i in assets)
					{
						remove(i);
					}
					switchState(new FreeplayState());
				}
			}
		}
	}

	public var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	public function getRatesScore(rate:Float, score:Float):Float
	{
		var rateX:Float = 1;
		var lastScore:Float = score;
		var pr = rate - 0.05;
		if (pr < 1.00)
			pr = 1;

		while (rateX <= pr)
		{
			if (rateX > pr)
				break;
			lastScore = score + ((lastScore * rateX) * 0.022);
			rateX += 0.05;
		}

		var actualScore = Math.round(score + (Math.floor((lastScore * pr)) * 0.022));

		return actualScore;
	}

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float;
		if (daNote != null)
			noteDiff = -(daNote.strumTime - Conductor.songPosition);
		else
			noteDiff = Conductor.safeZoneOffset; // Assumed SHIT if no note was given

		noteDiff -= FlxG.save.data.moffset;
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = Ratings.judgeNote(noteDiff);

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.1;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.06;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		if (songMultiplier >= 1.05)
			score = getRatesScore(songMultiplier, score);

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);

			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
			var pixelShitPart3:String = "shared";

			if (SONG.noteStyle == 'pixel')
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
				pixelShitPart3 = 'week6';
			}

			rating.loadGraphic(Paths.loadImage(pixelShitPart1 + daRating + pixelShitPart2, pixelShitPart3));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff / songMultiplier, 3);
			if (PlayStateChangeables.botPlay && !loadRep)
				msTiming = 0;

			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!PlayStateChangeables.botPlay || loadRep)
				add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'combo' + pixelShitPart2, pixelShitPart3));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay || loadRep)
				add(rating);

			if (SONG.noteStyle != 'pixel')
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = FlxG.save.data.antialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = FlxG.save.data.antialiasing;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * CoolUtil.daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * CoolUtil.daPixelZoom * 0.7));
			}

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (SONG.noteStyle != 'pixel')
				{
					numScore.antialiasing = FlxG.save.data.antialiasing;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * CoolUtil.daPixelZoom));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				visibleCombos.push(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						visibleCombos.remove(numScore);
						numScore.destroy();
					},
					onUpdate: function(tween:FlxTween)
					{
						if (!visibleCombos.contains(numScore))
						{
							tween.cancel();
							numScore.destroy();
						}
					},
					startDelay: Conductor.crochet * 0.002
				});

				if (visibleCombos.length > seperatedScore.length + 20)
				{
					for (i in 0...seperatedScore.length - 1)
					{
						visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
					}
				}

				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];
		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.visible && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					goodNoteHit(daNote);
				}
			});
		}

		if ((false && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					Debug.logTrace("kill dumbass");
					note.kill();
					note.alpha = 0;
					notes.remove(note, true);
					note.alive = false;
					note.destroy();
					/*if (executeModchart)
						ModchartState.shownNotes.remove(daNote.LuaNote); */
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false, false, false, false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.judgeNote(noteDiff);
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					{
						boyfriend.dance();
					}
					if (glitcherBF.animation.curAnim.name.startsWith('sing') && !glitcherBF.animation.curAnim.name.endsWith('miss'))
					{
						glitcherBF.dance();
					}
					if (glitcherRBF != null)
						if (glitcherRBF.animation.curAnim.name.startsWith('sing') && !glitcherRBF.animation.curAnim.name.endsWith('miss'))
						{
							glitcherRBF.dance();
						}
					if (coolingBF.animation.curAnim.name.startsWith('sing') && !coolingBF.animation.curAnim.name.endsWith('miss'))
					{
						coolingBF.dance();
					}
					if (lcdBF2 != null && lcdBF3 != null)
					{
						lcdBF2.dance();
						lcdBF3.dance();
					}
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there
		}
		if (PlayStateChangeables.botPlay)
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					// Force good note hit regardless if it's too late to hit it or not as a fail safe
					if (loadRep)
					{
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = 0;
						}
					}
					else
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = 0;
					}
				}
			});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')
				&& (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
				boyfriend.dance();
			if (glitched
				&& glitcherBF.animation.curAnim.name.startsWith('sing')
				&& !glitcherBF.animation.curAnim.name.endsWith('miss')
				&& (glitcherBF.animation.curAnim.curFrame >= 10 || glitcherBF.animation.curAnim.finished))
				glitcherBF.dance();
			if (dark
				&& coolingBF.animation.curAnim.name.startsWith('sing')
				&& !coolingBF.animation.curAnim.name.endsWith('miss')
				&& (coolingBF.animation.curAnim.curFrame >= 10 || coolingBF.animation.curAnim.finished))
				coolingBF.dance();
			if (glitcherRBF != null)
				if (glitcherRBF.animation.curAnim.name.startsWith('sing')
					&& !glitcherRBF.animation.curAnim.name.endsWith('miss')
					&& (glitcherRBF.animation.curAnim.curFrame >= 10 || glitcherRBF.animation.curAnim.finished))
					glitcherRBF.dance();
			if (lcdBF2 != null && lcdBF3 != null)
			{
				if (lcdBF2.animation.curAnim.name.startsWith('sing')
					&& !lcdBF2.animation.curAnim.name.endsWith('miss')
					&& (lcdBF2.animation.curAnim.curFrame >= 10 || lcdBF2.animation.curAnim.finished))
					lcdBF2.dance();
				if (lcdBF3.animation.curAnim.name.startsWith('sing')
					&& !lcdBF3.animation.curAnim.name.endsWith('miss')
					&& (lcdBF3.animation.curAnim.curFrame >= 10 || lcdBF3.animation.curAnim.finished))
					lcdBF3.dance();
			}
		}

		playerStrums.forEach(function(spr:StaticArrow)
		{
			if (!PlayStateChangeables.botPlay)
			{
				if (keys[spr.ID]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed'
					&& !spr.animation.curAnim.name.startsWith('dirCon'))
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('static', false);
			}
			else if (FlxG.save.data.cpuStrums)
			{
				if (spr.animation.finished)
					spr.playAnim('static');
			}
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public var fuckingVolume:Float = 1;
	public var useVideo = false;

	public static var webmHandler:WebmHandler;

	public var playingDathing = false;
	public var videoSprite:FlxSprite;

	public function backgroundVideo(source:String) // for background videos
	{
		#if FEATURE_WEBM
		useVideo = true;

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		// WebmPlayer.SKIP_STEP_LIMIT = 90;
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		add(videoSprite);
		add(gf);
		add(boyfriend);
		add(dad);

		trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			// health -= 0.2;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			if (combo != 0)
			{
				combo = 0;
				popUpScore(null);
			}
			misses++;

			if (daNote != null)
			{
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
					]);
					saveJudge.push("miss");
				}
			}
			else if (!loadRep)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
				]);
				saveJudge.push("miss");
			}

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;

			if (FlxG.save.data.missSounds)
			{
				FlxG.sound.play(Paths.soundRandom('missnote' + altSuffix, 1, 3, "shared"), FlxG.random.float(0.1, 0.2));
				// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
				// FlxG.log.add('played imss note');
			}

			if (Stage.curStage == "hexwstage" || (Stage.curStage == "hexwdg" && glitcherRBF.alpha == 1))
			{
				switch (direction)
				{
					case 0:
						direction = 3;
					case 3:
						direction = 0;
				}
			}

			// Hole switch statement replaced with a single line :)
			boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			if (glitched)
				glitcherBF.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			if (glitcherRBF != null)
				glitcherRBF.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			if (dark)
				coolingBF.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			if (lcdBF2 != null && lcdBF3 != null)
			{
				lcdBF2.playAnim('sing' + dataSuffix[direction] + 'miss', true);
				lcdBF3.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			}
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;

			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	 */
	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS,
			(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(accuracy, 0) : accuracy));
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;
	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(noteDiff);

		/* if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note, false);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note, false);
					}
				}
		}*/

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));

			/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false); */
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		if (!note.visible)
			return;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.judgeNote(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
			}

			var altAnim:String = "";
			if (note.isAlt)
			{
				altAnim = '-alt';
				trace("Alt note on BF");
			}

			var direction = note.noteData;

			if (Stage.curStage == "hexwstage" || (Stage.curStage == "hexwdg" && glitcherRBF.alpha == 1))
			{
				switch (direction)
				{
					case 0:
						direction = 3;
					case 3:
						direction = 0;
				}
			}
			boyfriend.playAnim('sing' + dataSuffix[direction] + altAnim, true);
			if (glitched)
				glitcherBF.playAnim('sing' + dataSuffix[direction], true);
			if (glitcherRBF != null)
				glitcherRBF.playAnim('sing' + dataSuffix[direction], true);
			if (dark)
				coolingBF.playAnim('sing' + dataSuffix[direction], true);
			if (lcdBF2 != null && lcdBF3 != null)
			{
				lcdBF2.playAnim('sing' + dataSuffix[direction], true);
				lcdBF3.playAnim('sing' + dataSuffix[direction], true);
			}
			if (Stage.curStage == "hexw" && doMoveArrows)
			{
				var offsetxx = 0;
				var offsetyy = 0;

				switch (note.noteData)
				{
					case 0:
						offsetxx = -24;
					case 1:
						offsetyy = 24;
					case 2:
						offsetyy = -24;
					case 3:
						offsetxx = 24;
				}

				camFollow.setPosition((boyfriend.getMidpoint().x - 192) + offsetxx, (boyfriend.getMidpoint().y - 100) + offsetyy);
			}

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			if (!PlayStateChangeables.botPlay || FlxG.save.data.cpuStrums)
			{
				playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, note);
				});
			}

			if (!note.isSustainNote)
			{
				note.visible = false;

				/*if (executeModchart)
					ModchartState.shownNotes.remove(daNote.LuaNote); */
			}
			else
			{
				note.wasGoodHit = true;
			}
			if (!note.isSustainNote)
				updateAccuracy();
		}
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (!FlxG.save.data.stepMania)
			{
				spr.playAnim('confirm', true);
			}
			else
			{
				spr.playAnim('dirCon' + daNote.originColor, true);
				spr.localAngle = daNote.originAngle;
			}
		}
	}

	var danced:Bool = false;
	var prevStep = 0;

	function darkF(go:Bool = true)
	{
		Debug.logTrace("dark mode");
		dark = go;
		if (go)
		{
			FlxTween.tween(Stage.swagBacks['hexBack'], {alpha: 0}, 0.3);
			FlxTween.tween(Stage.swagBacks['hexFront'], {alpha: 0}, 0.3);
			FlxTween.tween(Stage.swagBacks['topOverlay'], {alpha: 0}, 0.3);
			FlxTween.tween(Stage.swagBacks['crowd'], {alpha: 0}, 0.3);
			FlxTween.tween(Stage.swagBacks['hexDarkBack'], {alpha: 1}, 0.3);
			FlxTween.tween(Stage.swagBacks['hexDarkFront'], {alpha: 1}, 0.3);
			FlxTween.tween(Stage.swagBacks['topDarkOverlay'], {alpha: 1}, 0.3);
			FlxTween.tween(Stage.swagBacks['darkCrowd'], {alpha: 1}, 0.3);
			FlxTween.tween(coolingDad, {alpha: 1});
			FlxTween.tween(coolingGF, {alpha: 1});
			FlxTween.tween(coolingBF, {alpha: 1});
			FlxTween.tween(dad, {alpha: 0});
			FlxTween.tween(gf, {alpha: 0});
			FlxTween.tween(boyfriend, {alpha: 0});
		}
		else
		{
			FlxTween.tween(Stage.swagBacks['hexBack'], {alpha: 1}, 0.3);
			FlxTween.tween(Stage.swagBacks['hexFront'], {alpha: 1}, 0.3);
			FlxTween.tween(Stage.swagBacks['topOverlay'], {alpha: 1}, 0.3);
			FlxTween.tween(Stage.swagBacks['crowd'], {alpha: 1}, 0.3);
			FlxTween.tween(Stage.swagBacks['hexDarkBack'], {alpha: 0}, 0.3);
			FlxTween.tween(Stage.swagBacks['hexDarkFront'], {alpha: 0}, 0.3);
			FlxTween.tween(Stage.swagBacks['topDarkOverlay'], {alpha: 0}, 0.3);
			FlxTween.tween(Stage.swagBacks['darkCrowd'], {alpha: 0}, 0.3);
			FlxTween.tween(coolingDad, {alpha: 0});
			FlxTween.tween(coolingGF, {alpha: 0});
			FlxTween.tween(coolingBF, {alpha: 0});
			FlxTween.tween(dad, {alpha: 1});
			FlxTween.tween(gf, {alpha: 1});
			FlxTween.tween(boyfriend, {alpha: 1});
			var spot = Stage.swagBacks['breakSpot1'];
			var ospot = Stage.swagBacks['breakSpot0'];
			if (spot.alpha != 0 || ospot.alpha != 0)
			{
				FlxTween.tween(spot, {alpha: 0}, 0.45);
				FlxTween.tween(ospot, {alpha: 0}, 0.45);
			}
		}
	}

	override function stepHit()
	{
		super.stepHit();

		if (prevStep != curStep)
			prevStep = curStep;
		else
			return;

		if (!endingSong)
			if (Conductor.songPosition > FlxG.sound.music.time / songMultiplier + 25
				|| Conductor.songPosition < FlxG.sound.music.time / songMultiplier - 25)
			{
				resyncVocals();
			}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		if (Stage.curStage == "hexwdg")
		{
			switch (curStep)
			{
				case 576:
					FlxG.camera.flash(FlxColor.RED, 0.6);
					Stage.swagBacks['hexrBack'].alpha = 1;
					Stage.swagBacks['hexrFront'].alpha = 1;
					Stage.swagBacks['topOverlay'].alpha = 0;
					Stage.swagBacks['crowd'].alpha = 0;
					Stage.swagBacks['hexFront'].alpha = 0;
					Stage.swagBacks['hexBack'].alpha = 0;
					glitcherRDad.alpha = 1;
					glitcherRBF.alpha = 1;
					dad.alpha = 0;
					boyfriend.alpha = 0;
					gf.alpha = 0;
				case 832:
					FlxG.camera.flash(FlxColor.RED, 0.6);
					Stage.swagBacks['hexrBack'].alpha = 0;
					Stage.swagBacks['hexrFront'].alpha = 0;
					Stage.swagBacks['topOverlay'].alpha = 1;
					Stage.swagBacks['crowd'].alpha = 1;
					Stage.swagBacks['hexFront'].alpha = 1;
					Stage.swagBacks['hexBack'].alpha = 1;
					glitcherRDad.alpha = 0;
					glitcherRBF.alpha = 0;
					dad.alpha = 1;
					boyfriend.alpha = 1;
					gf.alpha = 1;
				case 1088:
					FlxG.camera.flash(FlxColor.RED, 0.6);
					Stage.swagBacks['hexrBack'].alpha = 1;
					Stage.swagBacks['hexrFront'].alpha = 1;
					Stage.swagBacks['topOverlay'].alpha = 0;
					Stage.swagBacks['crowd'].alpha = 0;
					Stage.swagBacks['hexFront'].alpha = 0;
					Stage.swagBacks['hexBack'].alpha = 0;
					glitcherRDad.alpha = 1;
					glitcherRBF.alpha = 1;
					dad.alpha = 0;
					boyfriend.alpha = 0;
					gf.alpha = 0;
				case 1344:
					FlxG.camera.flash(FlxColor.RED, 0.6);
					Stage.swagBacks['hexrBack'].alpha = 0;
					Stage.swagBacks['hexrFront'].alpha = 0;
					Stage.swagBacks['topOverlay'].alpha = 1;
					Stage.swagBacks['crowd'].alpha = 1;
					Stage.swagBacks['hexFront'].alpha = 1;
					Stage.swagBacks['hexBack'].alpha = 1;
					glitcherRDad.alpha = 0;
					glitcherRBF.alpha = 0;
					dad.alpha = 1;
					boyfriend.alpha = 1;
					gf.alpha = 1;
			}
		}

		if (Stage.curStage == "hexwstage")
		{
			switch (curStep)
			{
				case 512:
					bopOn = 1;
					lcdSwap(1);
				case 784:
					bopOn = 4;
					lcdSwap(2);
				case 1040:
					bopOn = 2;
					lcdSwap(0);
				case 1552:
					bopOn = 1;
					lcdSwap(1);
				case 1824:
					bopOn = 2;
					lcdSwap(0);
			}
		}

		if (Stage.curStage == "hexw" && SONG.songId.toLowerCase() == "cooling") // I dont wanna talk about this because of songMultiplier :(
		{
			if (curStep == Math.floor(272 * songMultiplier))
				bopOn = 4;
			if (curStep == Math.floor(400 * songMultiplier))
				bopOn = 2;
			if (curStep == Math.floor(526 * songMultiplier))
			{
				bopOn = 1;
				doMoveArrows = true;
			}
			if (curStep == Math.floor(768 * songMultiplier))
			{
				bopOn = 100;
				doMoveArrows = false;
			}
			if (curStep == Math.floor(783 * songMultiplier))
			{
				bopOn = 4;
				darkF();
			}
			if (curStep == Math.floor(912 * songMultiplier))
			{
				bopOn = 2;
			}
			if (curStep == Math.floor(1024 * songMultiplier))
			{
				bopOn = 100;
				darkF(false);
			}
			if (curStep == Math.floor(1040 * songMultiplier))
				bopOn = 4;
			if (curStep == Math.floor(1296 * songMultiplier))
				bopOn = 2;
			if (curStep == Math.floor(1408 * songMultiplier))
				bopOn = 100;
			if (curStep == Math.floor(1424 * songMultiplier))
			{
				bopOn = 1;
				doMoveArrows = true;
			}
			if (curStep == Math.floor(1664 * songMultiplier))
			{
				bopOn = 100;
				doMoveArrows = false;
			}
			if (curStep == Math.floor(1680 * songMultiplier))
				bopOn = 4;
		}

		if (Stage.curStage == "hexg")
		{
			if (curStep == Math.floor(576 * songMultiplier)
				|| curStep == Math.floor(828 * songMultiplier)
				|| curStep == Math.floor(1087 * songMultiplier)
				|| curStep == Math.floor(1332 * songMultiplier))
			{
				glitched = !glitched;
				if (glitched)
				{
					FlxTween.tween(Stage.swagBacks['glitcherStage'], {alpha: 1}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(Stage.swagBacks['unGlitchedStageFront'], {alpha: 0}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(Stage.swagBacks['unGlitchedBG'], {alpha: 0}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(dad, {alpha: 0}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(boyfriend, {alpha: 0}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(gf, {alpha: 0}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(glitcherDad, {alpha: 1}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(glitcherBF, {alpha: 1}, 0.15, {ease: FlxEase.linear});
				}
				else
				{
					FlxTween.tween(Stage.swagBacks['glitcherStage'], {alpha: 0}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(Stage.swagBacks['unGlitchedStageFront'], {alpha: 1}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(Stage.swagBacks['unGlitchedBG'], {alpha: 1}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(dad, {alpha: 1}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(boyfriend, {alpha: 1}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(gf, {alpha: 1}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(glitcherDad, {alpha: 0}, 0.15, {ease: FlxEase.linear});
					FlxTween.tween(glitcherBF, {alpha: 0}, 0.15, {ease: FlxEase.linear});
				}
			}
		}
	}

	public var bopOn:Int = 2;

	public var lerp:Float = 0;

	override function beatHit()
	{
		super.beatHit();

		lerp = 1;

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if ((Stage.curStage == "hexw" || Stage.curStage == "hexwd" || Stage.curStage == "hexwdg") && curBeat % bopOn == 0)
		{
			Stage.swagBacks['crowd'].animation.play("bop");
			if (dark)
				Stage.swagBacks['darkCrowd'].animation.play("bop");
		}

		if (Stage.curStage == "hexwstage" && curBeat % bopOn == 0)
		{
			Stage.swagBacks['lights1'].animation.play("bop");
			Stage.swagBacks['lights2'].animation.play("bop");
			Stage.swagBacks['lights3'].animation.play("bop");
			Stage.swagBacks['crowd1'].animation.play("bop");
			Stage.swagBacks['crowd2'].animation.play("bop");
			Stage.swagBacks['crowd3'].animation.play("bop");
		}
		if (currentSection != null)
		{
			if (curBeat % idleBeat == 0)
			{
				if (idleToBeat && !dad.animation.curAnim.name.startsWith('sing'))
					dad.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith('sing'))
				{
					boyfriend.dance(forcedToIdle, currentSection.playerAltAnim);
					if (boyfriend.animation.curAnim.name.startsWith('sing'))
						boyfriend.dance();
				}

				if (glitched && !boyfriend.animation.curAnim.name.startsWith('sing'))
					glitcherBF.dance();
				if (glitcherRBF != null && !glitcherRBF.animation.curAnim.name.startsWith('sing'))
					glitcherRBF.dance();
				if (dark && !boyfriend.animation.curAnim.name.startsWith('sing'))
					coolingBF.dance();
				if (lcdBF2 != null && lcdBF3 != null)
				{
					if (!lcdBF2.animation.curAnim.name.startsWith('sing'))
						lcdBF2.dance();
					if (!lcdBF3.animation.curAnim.name.startsWith('sing'))
						lcdBF3.dance();
				}
			}
			else if ((dad.curCharacter == 'spooky' || dad.curCharacter == 'gf') && !dad.animation.curAnim.name.startsWith('sing'))
				dad.dance(forcedToIdle, currentSection.CPUAltAnim);

			if (Stage.curStage == 'hexg')
			{
				if (glitched)
					if (!glitcherDad.animation.curAnim.name.startsWith('sing') && glitcherDad.animation.finished)
						glitcherDad.dance(forcedToIdle, currentSection.CPUAltAnim);
			}

			if (glitcherRDad != null)
				if (!glitcherRDad.animation.curAnim.name.startsWith('sing') && glitcherRDad.animation.finished)
					glitcherRDad.dance(forcedToIdle, currentSection.CPUAltAnim);

			if (Stage.curStage == "hexw")
			{
				if (dark)
					if (!coolingDad.animation.curAnim.name.startsWith('sing') && coolingDad.animation.finished)
						coolingDad.dance(forcedToIdle, currentSection.CPUAltAnim);
			}
			if (lcdDad2 != null && lcdDad3 != null)
			{
				if (!lcdDad2.animation.curAnim.name.startsWith('sing') && lcdDad2.animation.finished)
					lcdDad2.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (!lcdDad3.animation.curAnim.name.startsWith('sing') && lcdDad3.animation.finished)
					lcdDad3.dance(forcedToIdle, currentSection.CPUAltAnim);
			}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom && songMultiplier == 1)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (PlayState.SONG.songId == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}
		}

		if (!endingSong && currentSection != null)
		{
			if (allowedToHeadbang)
			{
				gf.dance();
				if (dark)
					coolingGF.dance();
				if (lcdGF2 != null && lcdGF3 != null)
				{
					lcdGF2.dance();
					lcdGF3.dance();
				}
			}

			if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			{
				boyfriend.playAnim('hey', true);
			}

			if (curBeat % 16 == 15 && SONG.songId == 'tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				if (vocals.volume != 0)
				{
					boyfriend.playAnim('hey', true);
					dad.playAnim('cheer', true);
				}
				else
				{
					dad.playAnim('sad', true);
					FlxG.sound.play(Paths.soundRandom('GF_', 1, 4, 'shared'), 0.3);
				}
			}

			if (PlayStateChangeables.Optimize)
				if (vocals.volume == 0 && !currentSection.mustHitSection)
					vocals.volume = 1;
		}
	}

	public var cleanedSong:SongData;

	function poggers(?cleanTheSong = false)
	{
		var notes = [];

		if (cleanTheSong)
		{
			cleanedSong = SONG;

			for (section in cleanedSong.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in cleanedSong.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
		else
		{
			for (section in SONG.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in SONG.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
	}
} // u looked :O -ides
