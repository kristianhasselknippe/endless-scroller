using Uno;
using Uno.UX;
using Uno.Collections;

using Fuse;
using Fuse.Controls;
using Fuse.Animations;
using Fuse.Elements;
using Fuse.Triggers.Actions;


public class SlotReel : Behavior
{

	Dictionary<Node,Translation> _transforms = new Dictionary<Node,Translation>();


	float _itemHeight = 50.0f;
	public float ItemHeight
	{
		get { return _itemHeight; }
		set
		{
			_itemHeight = value;
			SetTransforms();
		}
	}

	double _speed = 20.0f;
	public double Speed
	{
		get { return _speed; }
		set { _speed = value; }
	}

	double _time = 0;
	bool _playing = false;
	int _target = 0;

	public int Progress
	{
		get { return (int)(_time * _speed / ItemHeight); }
	}

	void Update()
	{
		if (!_playing)
			return;

		var dt = Time.FrameInterval;
		_time  += dt;
		SetTransforms();
	}


	public void SpinTo(int reelPosition)
	{
		_target = reelPosition;
		_playing = true;
	}

	int lastP = 0;
	void SetTransforms()
	{
		var totalHeight = _transforms.Keys.Count * ItemHeight;
		foreach (var n in _transforms.Keys)
		{
			var t = _transforms[n];
			t.Y = Math.Mod(-(float)(ItemHeight * _transforms.Keys.IndexOf(n) + _time * _speed), totalHeight);
		}
		if (Progress != lastP)
		{
			debug_log("Progress: " + Progress);
			lastP = Progress;
		}
	}

	public SlotReel()
	{

	}

	protected override void OnRooted(Node parentNode)
	{
		base.OnRooted(parentNode);
		var e = parentNode as Panel;
		if (e == null)
			throw new Exception("SlotSteel must be attached to an element type");
		e.ChildAdded += OnChildAdded;
		e.ChildRemoved += OnChildRemoved;

		foreach (var c in ((Panel)parentNode).Children)
		{
			var t = new Translation();
			_transforms.Add(c,t);
			c.Transforms.Add(t);
		}

		SetTransforms();
		UpdateManager.AddAction(Update);
	}

	protected override void OnUnrooted(Node parentNode)
	{
		base.OnUnrooted(parentNode);
		((Panel)parentNode).ChildAdded -= OnChildAdded;
		((Panel)parentNode).ChildRemoved -= OnChildRemoved;

		foreach (var c in ((Panel)parentNode).Children)
		{
			if (_transforms.Keys.Contains(c))
				if (c.Transforms.Contains(_transforms[c]))
					c.Transforms.Remove(_transforms[c]);
		}
		_transforms.Clear();

		UpdateManager.RemoveAction(Update);
	}

	void OnChildAdded(object s, Node n)
	{
		var t = new Translation();
		_transforms.Add(n,t);
		n.Transforms.Add(t);
		SetTransforms();
	}

	void OnChildRemoved(object s, Node child)
	{
		_transforms.Remove(child);
		SetTransforms();
	}

}

public class SpinTo : TriggerAction
{
	public SlotReel SlotReel { get; set; }
	public int ReelPosition { get; set; }

	protected override void Perform(Node target)
	{
		if (SlotReel != null)
		{
			debug_log("We are starting to spin");
			SlotReel.SpinTo(ReelPosition);
		}
	}

}
