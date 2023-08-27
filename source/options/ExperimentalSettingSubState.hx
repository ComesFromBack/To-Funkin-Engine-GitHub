package options;

class ExperimentalSettingSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Experimental Setting';
		rpcTitle = 'Warning: Some experimental options may break your game, so be turned on with caution'; //for Discord Rich Presence

		var option:Option = new Option('blueberry',
			'If checked...Wait, A blueberry????',
			'blueberry',
			'bool');
		addOption(option);

		var option:Option = new Option('Old Version Health Bar',
			'If checked, health bar support will be enabled in version 0.6.x',
			'oldVHB',
			'bool');
		addOption(option);

		var option:Option = new Option('Old Version Lua Support',
			'If checked, scripts support in version 0.6.x',
			'oldS',
			'bool');
		addOption(option);

		super();
	}
}
