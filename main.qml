import QtQuick 2.5
import QtQuick.Controls 1.4
import Fantti 1.0

ApplicationWindow
{
    width: 300
    height: 200
    title: "Simple"
    visible: true

    Image {
        id: sourceImage
        width: 80; height: width
        source: 'desert2.jpeg'
        visible: false;
    }

    Timer {
    	id: timer;
        interval: 30;
        running: true;
        repeat: true;
    	property real run_time: 0.0;

        onTriggered: {
        	run_time += interval / 1000.0;
        }
    }

	ShaderEffect {
		id: effect;
	    width: parent.width;
	    height: parent.height;

	    property variant source: sourceImage;

    	property real time: timer.run_time;
    	property real image_width: width;
    	property real image_height: height;
    }

    FileLoader {
    	files: [
            "prelude.glsl",
            "morpher.glsl",
            "materials.glsl",
            "simple_raycast.glsl"
        ]
    	onFileLoaded: { effect.fragmentShader = contents; }
    }
}