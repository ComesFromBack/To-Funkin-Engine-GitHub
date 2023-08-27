package other;

import haxe.io.Path;
import sys.FileSystem;

/**
 * ...
 * @author gelert
 */
class FileSystemHelper {

	/**
	 * Deletes the file (directory) specified by path (even if the directory isn't empty).
	 * 
	 * @param	path	Path to the file (directory) you want to delete.
	 * 					If path does not denote a valid file (directory),
	 * 					or if that file (directory) cannot be deleted,
	 * 					an exception is thrown.
	 * 					If path is null, the result is unspecified.
	 */
	public static function deletePath(path:String) {
		remove(Path.normalize(path));
	}
	
	static function remove(path:String) {
		if(FileSystem.isDirectory(path)) {
			var list = FileSystem.readDirectory(path);
			for(it in list) {
				remove(Path.join([path, it]));
			}
			FileSystem.deleteDirectory(path);
		} else {
			FileSystem.deleteFile(path);
		}
	}
}