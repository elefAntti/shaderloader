from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterType
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty
import json


def include_file(thing):
    if type(thing) == str:
        return open(thing, "r").read()
    if type(thing) == dict:
        defines = ["#define {} {}".format(key, val) for key, val in thing.items() if key != "files"]
        contents = include_file(thing["files"])
        undefines = ["#undef {}".format(key) for key in thing.keys() if key != "files"]
        defines = "\n".join(defines)
        undefines = "\n".join(undefines)
        return "\n".join([defines, contents, undefines])
    if type(thing) == list:
        return "\n".join(include_file(name) for name in thing)

def load_file(name):
    if name.endswith(".json"):
        content = json.loads(open(name, "r").read())
        return include_file(content)
    else:
        return open(name, "r").read()

class FileLoader(QObject):
    fileLoaded = pyqtSignal()
    def __init__(self, parent = None):
        QObject.__init__(self, parent)
        self._files=[]
        self._contents=""
    @pyqtProperty(list)
    def files(self):
        return self._files
    @files.setter
    def files(self, val):
        self._files=val
        self.read_files()
    @pyqtProperty(str)
    def contents(self):
        return self._contents
    def read_files(self):
        self._contents = "\n".join(load_file(name) for name in self._files)
        self.fileLoaded.emit()


qmlRegisterType(FileLoader, 'Fantti', 1, 0, 'FileLoader')

if __name__ == "__main__":
    import sys
    
    # Create an instance of the application
    app = QGuiApplication(sys.argv)
    # Create QML engine
    engine = QQmlApplicationEngine()
    # Load the qml file into the engine
    engine.load("main.qml")
    
    engine.quit.connect(app.quit)
    sys.exit(app.exec_())
