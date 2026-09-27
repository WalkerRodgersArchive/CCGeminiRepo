-- quanty.lua
-- CCVS Quaternion & Euler API Library for ComputerCraft/CC: Tweaked

-- Usage:
-- quanty = require("quanty")
-- local q = ship.getQuaternion()
-- local yaw = quanty.quaternionToYaw(q)

local quanty = {}

-- Converts a quaternion to yaw (rotation around Y axis, in radians)
function quanty.quaternionToYaw(q)
    local yaw = math.atan2(2 * (q.w * q.y + q.x * q.z), 1 - 2 * (q.y * q.y + q.x * q.x))
    return yaw
end

-- Converts a quaternion to pitch (rotation around X axis, in radians)
function quanty.quaternionToPitch(q)
    local sinp = 2 * (q.w * q.x - q.y * q.z)
    sinp = math.min(1, math.max(-1, sinp)) -- Clamp to avoid domain errors
    local pitch = math.asin(sinp)
    return pitch
end

-- Converts a quaternion to roll (rotation around Z axis, in radians)
function quanty.quaternionToRoll(q)
    local roll = math.atan2(2 * (q.w * q.z + q.y * q.x), 1 - 2 * (q.z * q.z + q.x * q.x))
    return roll
end

-- Converts radians to degrees
function quanty.radiansToDegrees(rad)
    return rad * (180 / math.pi)
end

-- Converts degrees to radians
function quanty.degreesToRadians(deg)
    return deg * (math.pi / 180)
end

-- Gets all Euler angles from a quaternion (in radians)
function quanty.quaternionToEuler(q)
    return {
        yaw = quanty.quaternionToYaw(q),
        pitch = quanty.quaternionToPitch(q),
        roll = quanty.quaternionToRoll(q)
    }
end

-- Gets all Euler angles from a quaternion (in degrees)
function quanty.quaternionToEulerDegrees(q)
    local euler = quanty.quaternionToEuler(q)
    return {
        yaw = quanty.radiansToDegrees(euler.yaw),
        pitch = quanty.radiansToDegrees(euler.pitch),
        roll = quanty.radiansToDegrees(euler.roll)
    }
end

-- Converts Euler angles (in radians) to a quaternion
function quanty.eulerToQuaternion(yaw, pitch, roll)
    local cy = math.cos(yaw * 0.5)
    local sy = math.sin(yaw * 0.5)
    local cp = math.cos(pitch * 0.5)
    local sp = math.sin(pitch * 0.5)
    local cr = math.cos(roll * 0.5)
    local sr = math.sin(roll * 0.5)

    return {
        w = cr * cp * cy + sr * sp * sy,
        x = sr * cp * cy - cr * sp * sy,
        y = cr * sp * cy + sr * cp * sy,
        z = cr * cp * sy - sr * sp * cy
    }
end

-- Normalizes a quaternion
function quanty.normalizeQuaternion(q)
    local mag = math.sqrt(q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z)
    return {
        w = q.w / mag,
        x = q.x / mag,
        y = q.y / mag,
        z = q.z / mag
    }
end

-- Multiplies two quaternions
function quanty.multiplyQuaternions(q1, q2)
    return {
        w = q1.w*q2.w - q1.x*q2.x - q1.y*q2.y - q1.z*q2.z,
        x = q1.w*q2.x + q1.x*q2.w + q1.y*q2.z - q1.z*q2.y,
        y = q1.w*q2.y - q1.x*q2.z + q1.y*q2.w + q1.z*q2.x,
        z = q1.w*q2.z + q1.x*q2.y - q1.y*q2.x + q1.z*q2.w
    }
end

-- Rotates a vector by a quaternion
function quanty.rotateVectorByQuaternion(v, q)
    -- v: {x, y, z}, q: {w, x, y, z}
    local qv = {w = 0, x = v.x, y = v.y, z = v.z}
    local q_conj = {w = q.w, x = -q.x, y = -q.y, z = -q.z}
    local result = quanty.multiplyQuaternions(quanty.multiplyQuaternions(q, qv), q_conj)
    return {x = result.x, y = result.y, z = result.z}
end

-- Returns a copy of the quaternion
function quanty.copyQuaternion(q)
    return {w = q.w, x = q.x, y = q.y, z = q.z}
end

-- Returns the conjugate of the quaternion
function quanty.conjugateQuaternion(q)
    return {w = q.w, x = -q.x, y = -q.y, z = -q.z}
end

-- Returns the magnitude of the quaternion
function quanty.magnitudeQuaternion(q)
    return math.sqrt(q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z)
end

-- Returns the inverse of the quaternion
function quanty.inverseQuaternion(q)
    local mag2 = q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z
    return {
        w = q.w / mag2,
        x = -q.x / mag2,
        y = -q.y / mag2,
        z = -q.z / mag2
    }
end

-- Export API table
return quanty