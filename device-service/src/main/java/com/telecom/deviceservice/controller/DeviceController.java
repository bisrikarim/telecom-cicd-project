package com.telecom.deviceservice.controller;

import com.telecom.deviceservice.model.Device;
import com.telecom.deviceservice.model.DeviceStatus;
import com.telecom.deviceservice.model.DeviceType;
import com.telecom.deviceservice.service.DeviceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/devices")
@RequiredArgsConstructor
@Tag(name = "Device Controller", description = "API pour la gestion des équipements télécom")
public class DeviceController {

    private final DeviceService deviceService;

    @GetMapping
    @Operation(summary = "Récupérer tous les équipements")
    public ResponseEntity<List<Device>> getAllDevices() {
        return ResponseEntity.ok(deviceService.getAllDevices());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Récupérer un équipement par son ID")
    public ResponseEntity<Device> getDeviceById(@PathVariable Long id) {
        return ResponseEntity.ok(deviceService.getDeviceById(id));
    }

    @GetMapping("/serial/{serialNumber}")
    @Operation(summary = "Récupérer un équipement par son numéro de série")
    public ResponseEntity<Device> getDeviceBySerialNumber(@PathVariable String serialNumber) {
        return ResponseEntity.ok(deviceService.getDeviceBySerialNumber(serialNumber));
    }

    @PostMapping
    @Operation(summary = "Créer un nouvel équipement")
    public ResponseEntity<Device> createDevice(@Valid @RequestBody Device device) {
        return new ResponseEntity<>(deviceService.createDevice(device), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour un équipement")
    public ResponseEntity<Device> updateDevice(@PathVariable Long id, @Valid @RequestBody Device device) {
        return ResponseEntity.ok(deviceService.updateDevice(id, device));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un équipement")
    public ResponseEntity<Void> deleteDevice(@PathVariable Long id) {
        deviceService.deleteDevice(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Mettre à jour le statut d'un équipement")
    public ResponseEntity<Device> updateDeviceStatus(@PathVariable Long id, @RequestParam DeviceStatus status) {
        return ResponseEntity.ok(deviceService.updateDeviceStatus(id, status));
    }

    @GetMapping("/type/{type}")
    @Operation(summary = "Récupérer les équipements par type")
    public ResponseEntity<List<Device>> getDevicesByType(@PathVariable DeviceType type) {
        return ResponseEntity.ok(deviceService.getDevicesByType(type));
    }

    @GetMapping("/status/{status}")
    @Operation(summary = "Récupérer les équipements par statut")
    public ResponseEntity<List<Device>> getDevicesByStatus(@PathVariable DeviceStatus status) {
        return ResponseEntity.ok(deviceService.getDevicesByStatus(status));
    }

    @GetMapping("/maintenance")
    @Operation(summary = "Récupérer les équipements nécessitant une maintenance")
    public ResponseEntity<List<Device>> getDevicesNeedingMaintenance() {
        return ResponseEntity.ok(deviceService.getDevicesNeedingMaintenance());
    }

    @GetMapping("/status-summary")
    @Operation(summary = "Récupérer un résumé des statuts des équipements")
    public ResponseEntity<Map<DeviceStatus, Long>> getDeviceStatusSummary() {
        return ResponseEntity.ok(deviceService.getDeviceStatusSummary());
    }
}