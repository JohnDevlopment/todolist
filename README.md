# todolist

A Godot-based GUI application for keeping a todo list. You can either download one of the releases or use Godot to export the project.

## Building From Source

The minimum required version of Godot is 3.4.1 stable. But you should use the latest stable Godot version. [Click here](https://godotengine.org/download) to download Godot.

The syntax for the commandline will be `godot --export PRESET PATH`, where "godot" is a path to the Godot binary or the name of a command. "PRESET" is an export preset: `Linux/X11` for Linux platforms and `Windows Desktop` for Windows platforms. You can also use `pck` to get the PCK file.

When you have downloaded and installed Godot, follow these steps.

Download the zip file and extract it, then change to the directory where `project.godot` resides. The next step is to input one of these commands into a command console.

### Linux

```shell
/path/to/godot3.4.1 --export Linux/X11 binfile
```

## Windows
```shell
/path/to/godot3.4.1 --export "Windows Desktop" binfile
```

- - -

This project was built using Godot 3.4.2 stable.
