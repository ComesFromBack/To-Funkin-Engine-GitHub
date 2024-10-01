package backend;

import backend.Song;

class DiffCounder {
    public static function getDiff(selectSong:SwagSong):Float {
        var ret:Float = 0;
        if(selectSong != null && !(ClientPrefs.getGameplaySetting("practice") || ClientPrefs.getGameplaySetting("botplay"))) {
            ret += getNotes(selectSong) / 100;
            ret += getNoteBPM_ABS(selectSong);
            ret += (ClientPrefs.getGameplaySetting("instakill") ? 1.2 : 0);
            ret += (ClientPrefs.getGameplaySetting("hard") ? 1.5 : 0);
            ret += getHealthGainOrLoss();
            ret *= ClientPrefs.getGameplaySetting("songspeed");

            return ret;
        } else {
            if(ClientPrefs.data.noReset)
                return 0;
            else
                return 0.1;
        }
        return 0;
    }

    inline static function getNotes(song:SwagSong):Int {
        var ret:Int = 0;
        if(!ClientPrefs.getGameplaySetting("opponentplay")) {
            for(note in song.notes)
                if(note.mustHitSection)
                    ret += 1;
        } else {
            for(note in song.notes)
                if(!note.mustHitSection)
                    ret += 1;
        }
        return ret;
    }

    static function getNoteBPM_ABS(song:SwagSong):Float {
        if(ClientPrefs.getGameplaySetting("scrolltype") == "multiplicative")
            return ClientPrefs.getGameplaySetting("scrollspeed")*song.bpm * song.speed / 100;
        else
            return ClientPrefs.getGameplaySetting("scrollspeed")*song.bpm / 100;

        return 0;
    }

    inline static function getHealthGainOrLoss():Float {
        return (1-ClientPrefs.getGameplaySetting("healthgain"))+(ClientPrefs.getGameplaySetting("healthloss")-1);
    }
}