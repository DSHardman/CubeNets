import adsk.core, adsk.fusion, traceback
import time


def updatefixedview(index, app, camera):
    # Top, Bottom, Front, Back, Left, Right, IsoTopLeft, IsoTopRight, IsoBottomLeft, IsoBottomRight
    match index:
        case 1:
            camera.viewOrientation = adsk.core.ViewOrientations.TopViewOrientation
        case 2:
            camera.viewOrientation = adsk.core.ViewOrientations.BottomViewOrientation
        case 3:
            camera.viewOrientation = adsk.core.ViewOrientations.FrontViewOrientation
        case 4:
            camera.viewOrientation = adsk.core.ViewOrientations.BackViewOrientation
        case 5:
            camera.viewOrientation = adsk.core.ViewOrientations.LeftViewOrientation
        case 6:
            camera.viewOrientation = adsk.core.ViewOrientations.RightViewOrientation
        case 7:
            camera.viewOrientation = adsk.core.ViewOrientations.IsoTopLeftViewOrientation
        case 8:
            camera.viewOrientation = adsk.core.ViewOrientations.IsoTopRightViewOrientation
        case 9:
            camera.viewOrientation = adsk.core.ViewOrientations.IsoBottomLeftViewOrientation
        case 10:
            camera.viewOrientation = adsk.core.ViewOrientations.IsoBottomRightViewOrientation

    app.activeViewport.camera = camera
    adsk.doEvents()
    app.activeViewport.refresh()


def updatespecificview(eye, target, up, app, camera):
    camera.eye = adsk.core.Point3D.create(eye[0], eye[1], eye[2])
    camera.target = adsk.core.Point3D.create(target[0], target[1], target[2])
    camera.up = adsk.core.Vector3D.create(up[0], up[1], up[2])

    app.activeViewport.camera = camera
    adsk.doEvents()
    app.activeViewport.refresh()


def main():
    ui = None

    try:
        app = adsk.core.Application.get()
        ui = app.userInterface

        camera = app.activeViewport.camera
        camera.isSmoothTransition = False
        camera.isFitView = True

        for i in range(5):
            updatefixedview(i+1, app, camera)
            time.sleep(2)

        for i in range(200):
            updatespecificview(eye=[-30, 15, i], target=[0, 0, 0], up=[0.3, 0.9, 0.3], app=app, camera=camera)
            time.sleep(0.01)

        for i in range(200):
            updatespecificview(eye=[-30+i, 15, 199], target=[0, 0, 0], up=[0.3, 0.9, 0.3], app=app, camera=camera)
            time.sleep(0.01)

        for i in range(200):
            updatespecificview(eye=[169, 15+i, 199], target=[0, 0, 0], up=[0.3, 0.9, 0.3], app=app, camera=camera)
            time.sleep(0.01)

        ui.messageBox('Finished!')

    except:
        if ui:
            ui.messageBox('Failed:\n{}'.format(traceback.format_exc()))


main()