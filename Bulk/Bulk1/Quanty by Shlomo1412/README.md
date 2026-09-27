# quanty.lua

**quanty** is a simple Lua API library for ComputerCraft/CC: Tweaked and CCVS (CC-VS ShipAPI) that provides easy-to-use functions for working with quaternions and Euler angles.  
This is useful for orientation, navigation, vector rotation, and interfacing with CCVS and VS ships or any system using quaternions.

## Features

- Convert between quaternions and Euler angles (yaw, pitch, roll)
- Convert radians to degrees and vice versa
- Normalize, copy, invert, and conjugate quaternions
- Multiply quaternions
- Rotate vectors by quaternions

## Installation

1. Download (or use wget) `quanty.lua` and save it to your ComputerCraft/CC:T computer or turtle.
2. Load the API in your program:

    ```lua
    os.loadAPI("quanty")
    ```

   Alternatively, if you use a modern CC: Tweaked setup, you can use `require`:

    ```lua
    local quanty = require("quanty")
    ```

## Usage

### Quaternion to Euler (radians/degrees)

```lua
local q = {w=1, x=0, y=0, z=0}
local eulerRad = quanty.quaternionToEuler(q)
print("Yaw:", eulerRad.yaw, "Pitch:", eulerRad.pitch, "Roll:", eulerRad.roll)

local eulerDeg = quanty.quaternionToEulerDegrees(q)
print("Yaw:", eulerDeg.yaw, "Pitch:", eulerDeg.pitch, "Roll:", eulerDeg.roll)
```

### Euler to Quaternion

```lua
local yaw = math.rad(45)
local pitch = math.rad(10)
local roll = math.rad(0)
local q = quanty.eulerToQuaternion(yaw, pitch, roll)
```

### Vector Rotation

```lua
local v = {x=1, y=0, z=0}
local q = {w=0.7071, x=0, y=0.7071, z=0}
local v_rot = quanty.rotateVectorByQuaternion(v, q)
print("Rotated vector:", v_rot.x, v_rot.y, v_rot.z)
```

### Utility Functions

```lua
local deg = quanty.radiansToDegrees(math.pi)
local rad = quanty.degreesToRadians(180)
local q_norm = quanty.normalizeQuaternion(q)
local q_copy = quanty.copyQuaternion(q)
local q_conj = quanty.conjugateQuaternion(q)
local q_inv = quanty.inverseQuaternion(q)
local mag = quanty.magnitudeQuaternion(q)
```

## API Reference

| Function                        | Description                                                      |
|----------------------------------|------------------------------------------------------------------|
| `quaternionToYaw(q)`             | Returns yaw (radians) from quaternion                            |
| `quaternionToPitch(q)`           | Returns pitch (radians) from quaternion                          |
| `quaternionToRoll(q)`            | Returns roll (radians) from quaternion                           |
| `quaternionToEuler(q)`           | Returns table of yaw, pitch, roll (radians)                      |
| `quaternionToEulerDegrees(q)`    | Returns table of yaw, pitch, roll (degrees)                      |
| `eulerToQuaternion(yaw,pitch,roll)` | Returns quaternion from Euler angles (radians)                |
| `radiansToDegrees(rad)`          | Converts radians to degrees                                      |
| `degreesToRadians(deg)`          | Converts degrees to radians                                      |
| `normalizeQuaternion(q)`         | Returns normalized quaternion                                    |
| `copyQuaternion(q)`              | Returns a copy of the quaternion                                 |
| `conjugateQuaternion(q)`         | Returns the conjugate of the quaternion                          |
| `inverseQuaternion(q)`           | Returns the inverse of the quaternion                            |
| `magnitudeQuaternion(q)`         | Returns the magnitude (norm) of the quaternion                   |
| `multiplyQuaternions(q1, q2)`    | Multiplies two quaternions                                       |
| `rotateVectorByQuaternion(v, q)` | Rotates vector v `{x,y,z}` by quaternion q                       |

## Example

```lua
os.loadAPI("quanty")
local q = {w=0.7071, x=0, y=0.7071, z=0}
local angles = quanty.quaternionToEulerDegrees(q)
print("Yaw: " .. angles.yaw .. " Pitch: " .. angles.pitch .. " Roll: " .. angles.roll)
```

## License

MIT

## Links

- [CC-VS ShipAPI Wiki](https://github.com/TechTastic/CC-VS/wiki/ShipAPI)
- [Quaternion Math (Wikipedia)](https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles)
