package backend;

class Highscore
{
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songRating:Map<String, Float> = new Map<String, Float>();
	public static var weekRating:Map<String, Float> = new Map<String, Float>();
	public static var songRanks:Map<String, Int> = new Map<String, Int>(); // Mic'd up

	public static var profileRanks:Map<String, Map<String, Map<String, Dynamic>>> = new Map();
	public static var profileList:Array<String> = [];

	public static function clearProfileRank(profileName:String, ?clearWeekRank:Bool = false):Void {
		if (profileRanks.exists(profileName)) {
			if (clearWeekRank)
				profileRanks.get(profileName).set("week", new Map<String, Map<String, Dynamic>>());
			else
				profileRanks.get(profileName).set("song", new Map<String, Map<String, Dynamic>>());

			FlxG.save.data.profileRanks = profileRanks;
			FlxG.save.flush();
		}
	}

	public static function removeProfile(profileName:String):Void {
		if (profileRanks.exists(profileName)) {
			profileRanks.remove(profileName);
			for(i in profileList)
				if (i == profileName) {
					profileList.remove(i);
					break; // end for
				}
			FlxG.save.data.profileRanks = profileRanks;
			FlxG.save.data.profileList = profileList;
			FlxG.save.flush();
		}
	}

	public static function writeToProfile(profileName:String, key:String, value:Dynamic) {
		if (profileRanks.exists(profileName)) {
			profileRanks.get(profileName).set(key, value);
			FlxG.save.data.profileRanks = profileRanks;
			FlxG.save.flush();
		}
	}

	public static function existsProfile(profileName:String):Bool {
		if(profileRanks.exists(profileName))
			return true;
		return false;
	}

	public static function renameProfile(scrProfileName:String, newProfileName:String):Void {
		if (profileRanks.exists(scrProfileName)) {
			profileRanks.set(newProfileName, profileRanks.get(scrProfileName));
			profileRanks.remove(scrProfileName);
			for(i in profileList)
				if (i == scrProfileName) {
					profileList.remove(i);
					profileList.push(newProfileName);
				}
			FlxG.save.data.profileRanks = profileRanks;
			FlxG.save.data.profileList = profileList;
			FlxG.save.flush();
		}
	}

	public static function createProfile(name:String):Void {
		if(!profileRanks.exists(name)) {
			profileRanks.set(name, new Map<String, Map<String, Dynamic>>());
			profileList.push(name);
		} else Log.LogPrint("Highscore.hx -> Func=createProfile(name:String):The profile name is same");
		FlxG.save.data.profileRanks = profileRanks;
		FlxG.save.data.profileList = profileList;
		FlxG.save.flush();
	}



	public static function resetSong(song:String, diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		setScore(daSong, 0);
		setRating(daSong, 0);
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
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}
	static function setWeekScore(week:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	static function setWeekAcc(week:String, acc:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekRating.set(week, acc);
		FlxG.save.data.weekRating = weekRating;
		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRating.set(song, rating);
		FlxG.save.data.songRating = songRating;
		FlxG.save.flush();
	}

	static function setRank(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRanks.set(song, score);
		FlxG.save.data.songRanks = songRanks;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		return Paths.formatToSongPath(song) + Difficulty.getFilePath(diff);
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

	public static function load():Void
	{
		if (FlxG.save.data.weekScores != null)
			weekScores = FlxG.save.data.weekScores;

		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;

		if (FlxG.save.data.songRating != null)
			songRating = FlxG.save.data.songRating;

		if (FlxG.save.data.weekRating != null)
			weekRating = FlxG.save.data.weekRating;

		if (FlxG.save.data.profileRanks != null)
			profileRanks = FlxG.save.data.profileRanks;

		if (FlxG.save.data.profileList != null)
			profileList = FlxG.save.data.profileList;

		if (FlxG.save.data.songRanks != null)
			songRanks = FlxG.save.data.songRanks;
	}
}