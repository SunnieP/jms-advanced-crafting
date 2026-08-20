JMSPlacement = {}
local placing = false

--- Shared ghost placement flow for both admin fixed-bench creation and portable bench deployment.
--- @param model number hash of the prop to preview
--- @param onConfirm function(coords: vector3, heading: number) called when the player confirms placement
--- @param onCancel function() called when the player cancels placement
function JMSPlacement.Start(model, onConfirm, onCancel)
    if placing then
        lib.notify({ description = 'Already placing a bench.', type = 'error' })
        return
    end

    placing = true

    lib.requestModel(model)

    local ped = PlayerPedId()
    local forward = GetEntityForwardVector(ped)
    local startCoords = GetEntityCoords(ped) + forward * 1.5

    local ghost = CreateObject(model, startCoords.x, startCoords.y, startCoords.z, false, false, false)
    SetEntityAlpha(ghost, 150, false)
    SetEntityCollision(ghost, false, false)

    local heading = GetEntityHeading(ped)
    local moveStep = 0.02

    lib.notify({ description = 'Move with your camera, Q/E to rotate, E to confirm, Backspace to cancel.', type = 'inform' })

    CreateThread(function()
        while placing do
            Wait(0)

            local camCoords = GetFinalRenderedCamCoord()
            local camRot = GetFinalRenderedCamRot(2)
            local camForward = RotationToDirection(camRot)
            local targetCoords = camCoords + camForward * 2.5

            local foundGround, groundZ = GetGroundZFor_3dCoord(targetCoords.x, targetCoords.y, targetCoords.z + 5.0, false)
            local placeZ = foundGround and groundZ or targetCoords.z

            SetEntityCoords(ghost, targetCoords.x, targetCoords.y, placeZ, false, false, false, false)
            SetEntityHeading(ghost, heading)

            if IsControlPressed(0, 44) then -- Q
                heading = (heading - 1.5) % 360.0
            elseif IsControlPressed(0, 38) then -- E rotate combo not used, E is confirm below
            end

            if IsControlJustReleased(0, 47) then -- G rotate right (alt key, avoids clashing with confirm)
                heading = (heading + 1.5) % 360.0
            end

            if IsControlJustReleased(0, 38) then -- E confirm
                local finalCoords = GetEntityCoords(ghost)
                placing = false
                DeleteObject(ghost)
                SetModelAsNoLongerNeeded(model)
                onConfirm(vector3(finalCoords.x, finalCoords.y, finalCoords.z), heading)
                return
            end

            if IsControlJustReleased(0, 194) then -- Backspace cancel
                placing = false
                DeleteObject(ghost)
                SetModelAsNoLongerNeeded(model)
                if onCancel then onCancel() end
                return
            end
        end
    end)
end

function JMSPlacement.IsActive()
    return placing
end
