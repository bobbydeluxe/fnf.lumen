package options;

class BaseGameSubState extends BaseOptionsMenu {
    public function new() {
        title = "V-Slice settings";
        rpcTitle = "V-Slice settings menu";
		
		var option:Option = new Option('Smooth health bar',
			'If enabled makes health bar move more smoothly',
			'vsliceSmoothBar',
			'bool');
		addOption(option);
		var option:Option = new Option('Force "New" tag',
			'If enabled will force every uncompleted song to show "new" tag even if it\'s disabled',
			'vsliceForceNewTag',
			'bool');
		addOption(option);
        super();
    }
}