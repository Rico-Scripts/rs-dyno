Config = {}
Config.NotifyTitle = 'RS Bike Dyno'
Config.OpenCommand = 'rsdyno'
Config.OpenKey = 'O'
Config.TargetDistance = 2.2
Config.MotorcycleClass = 8
Config.Performance = {
    stage2 = { dynoMultiplier = 1.12 },
    sportExhaust = { dynoMultiplier = 1.04 }
}
Config.Dyno = {
    coords = vec3(1000.984620, -2514.171386, 27.679078),
    radius = 2.5,
    targetIcon = 'fa-solid fa-gauge-high',
    targetLabel = 'Dyno testbank',
    duration = 14000,
    maxVehicleDistance = 4.0,
    freezeVehicle = true,
    baseHorsepower = 90,
    baseTorque = 95,
    modelMultipliers = {
        bati=1.35, bati2=1.38, hakuchou=1.45, hakuchou2=1.62,
        carbonrs=1.32, double=1.28, akuma=1.25, vortex=1.30,
        defiler=1.34, lectro=1.20, nemesis=1.08, daemon=0.92,
        daemon2=0.94, wolfsbane=0.95, gargoyle=1.05, sanchez=0.88, sanchez2=0.88
    }
}
