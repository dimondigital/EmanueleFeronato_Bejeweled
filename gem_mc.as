package {
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	
	public class gem_mc extends MovieClip {
		
		public function gem_mc(val:uint,  row:uint, col:uint) {
			gotoAndStop(val+1);
			name=row+"_"+col;
			x=col*60;
			y=row*60;
		
		}
	}
	
}