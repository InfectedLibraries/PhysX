set(INFECTED_PHYSX_SOURCES)
set(INFECTED_PHYSX_INTERFACE_SOURCES)
set(INFECTED_PHYSX_INCLUDE_DIRECTORIES)
set(INFECTED_PHYSX_INTERFACE_INCLUDE_DIRECTORIES)
set(INFECTED_PHYSX_COMPILE_DEFINITIONS)
set(INFECTED_PHYSX_INTERFACE_COMPILE_DEFINITIONS)

function(infected_physx_target_copy OTHER_TARGET)
    macro(copy_property PROPERTY_NAME)
        set(INFECTED_PHYSX_PROPERTY INFECTED_PHYSX_${PROPERTY_NAME})
        get_target_property(TEMP ${OTHER_TARGET} ${PROPERTY_NAME})
        list(APPEND ${INFECTED_PHYSX_PROPERTY} ${TEMP})
        set(${INFECTED_PHYSX_PROPERTY} ${${INFECTED_PHYSX_PROPERTY}} PARENT_SCOPE)
    endmacro()

    copy_property(SOURCES)
    copy_property(INTERFACE_SOURCES)
    copy_property(INCLUDE_DIRECTORIES)
    copy_property(INTERFACE_INCLUDE_DIRECTORIES)
    copy_property(COMPILE_DEFINITIONS)
    copy_property(INTERFACE_COMPILE_DEFINITION)
endfunction()

# Import properties from other PhysX projects
infected_physx_target_copy(PhysXFoundation)
infected_physx_target_copy(LowLevel)
infected_physx_target_copy(LowLevelAABB)
infected_physx_target_copy(LowLevelDynamics)
infected_physx_target_copy(PhysX)
infected_physx_target_copy(PhysXCharacterKinematic)
infected_physx_target_copy(PhysXCommon)
infected_physx_target_copy(PhysXCooking)
infected_physx_target_copy(PhysXExtensions)
infected_physx_target_copy(PhysXVehicle)
infected_physx_target_copy(SceneQuery)
infected_physx_target_copy(SimulationController)
infected_physx_target_copy(FastXml)
infected_physx_target_copy(PhysXPvdSDK)
infected_physx_target_copy(PhysXTask)

# De-dupe the properties
list(REMOVE_DUPLICATES INFECTED_PHYSX_SOURCES)
list(REMOVE_DUPLICATES INFECTED_PHYSX_INTERFACE_SOURCES)
list(REMOVE_DUPLICATES INFECTED_PHYSX_INCLUDE_DIRECTORIES)
list(REMOVE_DUPLICATES INFECTED_PHYSX_INTERFACE_INCLUDE_DIRECTORIES)
list(REMOVE_DUPLICATES INFECTED_PHYSX_COMPILE_DEFINITIONS)
list(REMOVE_DUPLICATES INFECTED_PHYSX_INTERFACE_COMPILE_DEFINITIONS)

# Remove resource files
list(FILTER INFECTED_PHYSX_SOURCES EXCLUDE REGEX .+/PhysX[A-Za-z]*.rc)

# Remove direct inclusion of FastXML object files done by PhysXExtensions
list(REMOVE_ITEM  INFECTED_PHYSX_SOURCES $<TARGET_OBJECTS:FastXml>)

# Add module definition
list(APPEND INFECTED_PHYSX_SOURCES "${PHYSX_ROOT_DIR}/../../../InfectedPhysX/#Generated/InfectedPhysX.def")
list(APPEND INFECTED_PHYSX_SOURCES "${PHYSX_ROOT_DIR}/../../../InfectedPhysX/#Generated/InfectedPhysX.cpp")

# Create our project
add_library(InfectedPhysX.Native SHARED)
set_target_properties(InfectedPhysX.Native PROPERTIES
    OUTPUT_NAME InfectedPhysX.Native

    SOURCES "${INFECTED_PHYSX_SOURCES}"
    INTERFACE_SOURCES "${INFECTED_PHYSX_INTERFACE_SOURCES}"
    INCLUDE_DIRECTORIES "${INFECTED_PHYSX_INCLUDE_DIRECTORIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${INFECTED_PHYSX_INTERFACE_INCLUDE_DIRECTORIES}"
    COMPILE_DEFINITIONS "${INFECTED_PHYSX_COMPILE_DEFINITIONS}"
    INTERFACE_COMPILE_DEFINITIONS "${INFECTED_PHYSX_INTERFACE_COMPILE_DEFINITIONS}"
)

# Pretty sure this should not be necessary, but this is needed for PVD support in checked builds
# Possibly related to https://github.com/InfectedLibraries/PhysX/issues/1
add_compile_definitions(InfectedPhysX.Native PX_SUPPORT_PVD=1)

# InfectedPhysX.cpp must be built with /Ob0 /Od as a workaround for https://github.com/InfectedLibraries/Biohazrd/issues/78
set_source_files_properties("${PHYSX_ROOT_DIR}/../../../InfectedPhysX/#Generated/InfectedPhysX.cpp" PROPERTIES COMPILE_FLAGS "/Ob0 /Od")
