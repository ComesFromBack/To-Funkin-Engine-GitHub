package backend;

import flixel.util.FlxSave;

class Highscore {
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songEndlessScores:Map<String, Int> = new Map<String, Int>();
	public static var songRating:Map<String, Float> = new Map<String, Float>();
	public static var songLoops:Map<String, Int> = new Map<String, Int>();
	public static var weekRating:Map<String, Float> = new Map<String, Float>();
	public static var songRanks:Map<String, Int> = new Map<String, Int>(); // Mic'd up

	public static var ScoreSave:FlxSave;
	public static var WeekSave:FlxSave;
	public static var EndlessSave:FlxSave;

	public static function resetSong(song:String, diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		setScore(daSong, 0);
		setRating(daSong, 0);
		setEndlessScore(daSong, 0);
		setLoops(daSong, 0);
	}

	public static function resetWeek(week:String, diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		setWeekScore(daWeek, 0);
		setWeekAcc(daWeek, 0.00);
	}

	public static function resetRank(song:String, diff:Int = 0):Void
	{
		var daWeek:String = formatSong(song, diff);
		setRank(daWeek, 17);
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1):Void
	{
		if(song == null) return;
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
			{
				setScore(daSong, score);
				if(rating >= 0) setRating(daSong, rating);
			}
		}
		else
		{
			setScore(daSong, score);
			if(rating >= 0) setRating(daSong, rating);
		}
	}

	public static function saveEndlessScore(song:String, score:Int = 0, loops:Int = 0, ?diff:Int = 0, ?rating:Float = -1):Void
	{
		if(song == null) return;
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
			{
				setEndlessScore(daSong, score);
				if(rating >= 0) setRating(daSong, rating);
				setLoops(daSong, loops);
			}
		}
		else
		{
			setEndlessScore(daSong, score);
			if(rating >= 0) setRating(daSong, rating);
			setLoops(daSong, loops);
		}
	}

	public static function saveRank(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songRanks.exists(daSong)) {
			if (songRanks.get(daSong) > score)
				setRank(daSong, score);
		}
		else
			setRank(daSong, score);
	}

	public static function saveWeekScore(week:String, score:Int = 0, acc:Float = 0.00, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);

		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score)
				setWeekScore(daWeek, score);

			if (weekRating.get(daWeek) < acc)
				setWeekAcc(daWeek, acc);
		}
		else {
			setWeekScore(daWeek, score);
			setWeekAcc(daWeek, acc);
		}
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		ScoreSave.data.songScores = songScores;
		ScoreSave.flush();
	}

	static function setEndlessScore(song:String, score:Int):Void {
		songEndlessScores.set(song, score);
		EndlessSave.data.songEndlessScores = songEndlessScores;
		EndlessSave.flush();
	}

	static function setLoops(song:String, loops:Int):Void {
		songLoops.set(song, loops);
		EndlessSave.data.songLoops = songLoops;
		EndlessSave.flush();
	}

	static function setWeekScore(week:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		WeekSave.data.weekScores = weekScores;
		WeekSave.flush();
	}

	static function setWeekAcc(week:String, acc:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekRating.set(week, acc);
		WeekSave.data.weekRating = weekRating;
		WeekSave.flush();
	}

	static function setRating(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRating.set(song, rating);
		ScoreSave.data.songRating = songRating;
		ScoreSave.flush();
	}

	static function setRank(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRanks.set(song, score);
		ScoreSave.data.songRanks = songRanks;
		ScoreSave.flush();
	}

	public static function formatSong(song:String, diff:Int):String {
		return '${Paths.formatToSongPath(song)}${Difficulty.getFilePath(diff)}';
	}

	public static function getEndless(song:String, diff:Int):Int {
		var daSong:String = formatSong(song, diff);
		if (!songEndlessScores.exists(daSong))
			setEndlessScore(daSong, 0);

		return songEndlessScores.get(daSong);
	}

	public static function getLoops(song:String, diff:Int):Int {
		var daSong:String = formatSong(song, diff);
		if (!songEndlessScores.exists(daSong))
			setLoops(daSong, 0);

		return songLoops.get(daSong);
	}

	public static function getScore(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}

	public static function getRating(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!songRating.exists(daSong))
			setRating(daSong, 0);

		return songRating.get(daSong);
	}

	public static function getRank(song:String, diff:Int):Int
	{
		if (!songRanks.exists(formatSong(song, diff)))
			setRank(formatSong(song, diff), 17);

		return songRanks.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setWeekScore(daWeek, 0);

		return weekScores.get(daWeek);
	}

	public static function getWeekAcc(week:String, diff:Int):Float
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekRating.exists(daWeek))
			setWeekAcc(daWeek, 0.00);

		return weekRating.get(daWeek);
	}

	public static function load():Void {
		ScoreSave = new FlxSave();
		ScoreSave.bind("SingleSong",CoolUtil.getSavePath()+"/score/");
		WeekSave = new FlxSave();
		WeekSave.bind("WeekScore",CoolUtil.getSavePath()+"/score/");
		EndlessSave = new FlxSave();
		EndlessSave.bind("EndlessScore",CoolUtil.getSavePath()+"/score/");

		if(WeekSave.data.weekScores != null)
			weekScores = WeekSave.data.weekScores;

		if(ScoreSave.data.songScores != null)
			songScores = ScoreSave.data.songScores;

		if(EndlessSave.data.songEndlessScores != null)
			songEndlessScores = EndlessSave.data.songEndlessScores;

		if(EndlessSave.data.songLoops != null)
			songLoops = EndlessSave.data.songLoops;

		if (ScoreSave.data.songRating != null)
			songRating = ScoreSave.data.songRating;

		if (WeekSave.data.weekRating != null)
			weekRating = WeekSave.data.weekRating;

		if (ScoreSave.data.songRanks != null)
			songRanks = ScoreSave.data.songRanks;
	}
}