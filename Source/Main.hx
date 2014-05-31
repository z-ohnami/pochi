package;


import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;

class Main extends Sprite {

	private static var WIDTH:Int = 50;
	private static var HEIGHT:Int = 50;
	private var map:Array<Array<String>>;

	public function new () {

		super ();

		init();

	}

	private function init():Void
	{
		map = [];
		for (y in 0...HEIGHT) {
			map[y] = [];
			for (x in 0...WIDTH) {
				map[y][x] = ' ';
			}
		}

		var splitArray:Array<Dynamic> = split(new Rect(0, 0, WIDTH - 1, HEIGHT - 1));
		var partitions:Array<Rect> = [];

		for (i in splitArray) {
			partitions.push(cast(i,Rect));
		}

		var rooms:Array<Rect> = [];

		var pl:Int = partitions.length;
		for (i in 0...pl) {
			rooms.push(createRoom(partitions[i]));
//			fill(partitions[i],'.');
			fill(rooms[i],'*');
		}

		connectRooms(partitions, rooms);

		var tf:TextField = new TextField();
		var format:TextFormat = new TextFormat("_typeWriter", 12, 0x0, true);
		format.leading = -8;
		tf.defaultTextFormat = format;
		tf.autoSize = TextFieldAutoSize.LEFT;
		addChild(tf);

		var ml:Int = map.length;
		for (i in 0...ml)
		{
			tf.appendText(map[i].join("") + "\n");
		}

	}

	private function fill(rect:Rect, char:String):Void
	{
		var minY:Int = cast(Math.min(rect.top, rect.bottom),Int);
		var maxY:Int = cast(Math.max(rect.top, rect.bottom),Int);

		var minX:Int = cast(Math.min(rect.left, rect.right),Int);
		var maxX:Int = cast(Math.max(rect.left, rect.right),Int);

		for (y in minY...maxY+1)
		{
			for (x in minX...maxX+1)
			{
				map[y][x] = char;
			}
		}
	}

	private function connectRooms(partitions:Array<Rect>, rooms:Array<Rect>):Void
	{
		var list:Array<Dynamic> = [];

		for (i in 0...(partitions.length - 1)) {
			list.push([i, i + 1]);
		}

		//Add random factor
		for (i in 0...partitions.length) {
			for (j in (i+2)...partitions.length) {
				if (partitions[i].left   - 1 == partitions[j].right  + 1 ||
					partitions[i].right  + 1 == partitions[j].left   - 1 ||
					partitions[i].top	 - 1 == partitions[j].bottom + 1 ||
					partitions[i].bottom + 1 == partitions[j].top    - 1)
				{
					if (Math.random() < 0.2) list.push([i, j]);
				}
			}
		}


		for (item in list) {
			connect(partitions[item[0]], partitions[item[1]], rooms[item[0]], rooms[item[1]]);
		}
	}

	private function connect(part0:Rect, part1:Rect, room0:Rect, room1:Rect):Void
	{
		var char:String = "+";
		var posA:Int;
		var posB:Int;

		// 縦に分割している場合
		if ((part0.bottom + 1) == (part1.top - 1))
		{
			posA = room0.left + getIntRandom(room0.width - 1);
			posB = room1.left + getIntRandom(room1.width - 1);

			fill(new Rect(posA, room0.bottom + 1, posA, part0.bottom + 1), char);
			fill(new Rect(posB, room1.top - 1, posB, part1.top - 1), char);
			fill(new Rect(posA, part0.bottom + 1, posB, part1.top - 1), char);
		}
		// 横に分割している場合
		else if (part0.right + 1 == part1.left - 1)
		{
			posA = room0.top + getIntRandom(room0.height - 1);
			posB = room1.top + getIntRandom(room1.height - 1);

			fill(new Rect(room0.right + 1, posA, part0.right + 1, posA), char);
			fill(new Rect(room1.left - 1, posB, part1.left - 1, posB), char);
			fill(new Rect(part0.right + 1, posA, part1.left - 1, posB), char);
		}
	}


	private function split(rect:Rect):Array<Dynamic>
	{
		var MIN_SIZE:Int = 8;

		if (rect.height < MIN_SIZE * 2 + 1 ||
			rect.width	< MIN_SIZE * 2 + 1)
		{
			return [rect];
		}

		var rectA:Rect;
		var rectB:Rect;

		var dirSplitFlag:Bool = true; // true = 縦に分割, false = 横に分割
		if (rect.height < MIN_SIZE * 2 + 1) dirSplitFlag = false;
		else if (rect.width < MIN_SIZE * 2 + 1) dirSplitFlag = true;
		else dirSplitFlag = (rect.width < rect.height) ? true : false;

		// 縦に分割
		if (dirSplitFlag)
		{
			var height:Int = rect.top + (MIN_SIZE - 1) + getIntRandom(rect.height - MIN_SIZE * 2 - 1);
			rectA = new Rect(rect.left, rect.top, rect.right, height);
			rectB = new Rect(rect.left, height + 2, rect.right, rect.bottom);
		}
		// 横に分割
		else
		{
			var width:Int = rect.left + (MIN_SIZE - 1) + getIntRandom(rect.width - MIN_SIZE * 2 - 1);
			rectA = new Rect(rect.left, rect.top, width, rect.bottom);
			rectB = new Rect(width + 2, rect.top, rect.right, rect.bottom);
		}

		return flatten([rectA, rectB].map(split));
	}

	private function getIntRandom(n:Int):Int
	{
		n += if(n < 0) -1 else 1;
		return Std.random(n);
	}

	private function flatten(data:Array<Dynamic>):Array<Dynamic>
	{
		var src:Array<Dynamic> = data.slice(0);
		var dest:Array<Dynamic> = [];

		while (true)
		{
			var element:Array<Dynamic> = src.shift();
			if (element == null) {
				break;
			} else if (Std.is(element,Array)) {
				src = src.concat(element);
			} else {
				dest.push(element);
			}
		}

		return dest;
	}

	private function createRoom(rect:Rect):Rect
	{
		var MIN_SIZE:Int = 6;

		var width:Int = MIN_SIZE + getIntRandom(rect.width - MIN_SIZE - 2);
		var height:Int = MIN_SIZE + getIntRandom(rect.height - MIN_SIZE - 2);

		var startX:Int = rect.left + 1 + getIntRandom(rect.width - width - 2);
		var startY:Int = rect.top + 1 + getIntRandom(rect.height - height - 2);

		return new Rect(startX, startY, startX + width - 1, startY + height - 1);
	}

}

class Rect
{
	public var left:Int;
	public var top:Int;
	public var right:Int;
	public var bottom:Int;

	public var height(get,never):Int;
	public var width(get,never):Int;

	public function new(left:Int = 0,top:Int = 0,right:Int = 0,bottom:Int = 0):Void {
		this.left = left;
		this.top = top;
		this.right = right;
		this.bottom = bottom;
	}

	public function get_height():Int {
		return bottom - top + 1;
	}

	public function get_width():Int {
		return right - left + 1;
	}

}