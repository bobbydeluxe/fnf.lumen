package backend;

class StateScriptBank {
	private static var _data:Map<String, Dynamic> = new Map();

	public static function set(key:String, value:Dynamic):Void _data.set(key, value);
	public static function get(key:String):Dynamic return _data.get(key);
	public static function has(key:String):Bool return _data.exists(key);
	public static function remove(key:String):Void _data.remove(key);
	public static function clear():Void _data.clear();
	public static function keys():Array<String> return [for (k in _data.keys()) k];
	public static function insert(key:String, value:Dynamic):Void {
		var list = get(key);
		if (list == null || !Std.isOfType(list, Array)) {
			list = [];
			set(key, list);
		}
		list.push(value);
	}
	public static function removeFrom(key:String, value:Dynamic):Void {
		var list = get(key);
		if (list != null && Std.isOfType(list, Array)) {
			list.remove(value);
		}
	}
}
