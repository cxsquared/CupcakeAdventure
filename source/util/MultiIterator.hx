package util;

class MultiIterator
{

    private var limit:Int;
    private var step:Int;
    private var i:Int;

    public function new(start:Int, end:Int, step:Int)
    {
        this.i = start;
        this.limit = end;
        this.step = step;
    }

    public function hasNext():Bool
    {
        return (i + step) <= limit;
    }

    public function next():Int
    {
        return i += step;
    }
}