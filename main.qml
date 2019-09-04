import QtQuick 2.5
import QtQuick.Controls 1.4
import Fantti 1.0

ApplicationWindow
{
    width: 640
    height: 480
    title: "Shader effect"
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
            "utils.glsl",
            //"test.glsl"
            "models/field_of_pillars.glsl", //Select the rendered model here (eg. torus_model.glsl, meta_model.glsl, morpher.glsl)
            "materials.glsl",
            //"glow_raycast.glsl"
            "simple_raycast.glsl"
        ]
    	onFileLoaded: { effect.fragmentShader = contents; }
    }
}