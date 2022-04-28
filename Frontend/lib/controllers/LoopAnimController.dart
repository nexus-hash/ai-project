import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flutter/material.dart';

class LoopAnimController implements FlareController {
    String _animation;
    double _loopAmount;
    double _mix;
    bool _active;
    ActorAnimation _act;
    double _duration = 0.0;
    FlutterActorArtboard _actorArtboard;

    LoopAnimController(this._animation, [this._loopAmount = -1.0, this._mix = 0.5]);
    // _loopAmount = -1 -> loop from start
    // _loopAmount = -2 -> don't loop

    @override
    void initialize(FlutterActorArtboard artboard) {
        _actorArtboard = artboard;
        _act = artboard.getAnimation(_animation);
        _active = true;

        if (_loopAmount == -1) {
            _loopAmount = _act.duration; // if no _loopAmount given, loop the whole animation
        }
    }

    set animation(String animation) {
        _animation = animation;
        initialize(_actorArtboard);
    }

    set loopAmt(double loopamt) {
        _loopAmount = loopamt;

        if (_loopAmount == -1) {
            _loopAmount = _act.duration; // if no _loopAmount given, loop the whole animation
        }
    }

    @override
    void setViewTransform(Mat2D viewTransform) {}

    @override
    bool advance(FlutterActorArtboard artboard, double elapsed) {
        if (!_active) {
            return true;
        }
        _duration += elapsed;

        // _loopAmount == -2 implies no looping
        if (_duration > _act.duration && !(_loopAmount == -2)) {
            final double loopStart = _act.duration - _loopAmount;
            final double loopProgress = _duration - _act.duration;
            _duration = loopStart + loopProgress;
        }
        _act.apply(_duration, artboard, _mix);
        return true;
    }

    get isActive {
        return ValueNotifier<bool>(_active);
    }

    set isActive(ValueNotifier<bool> setActive) {
        _active = setActive.value;
    }
}