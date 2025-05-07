package com.telecom.deviceservice.service;

import com.telecom.deviceservice.exception.DeviceNotFoundException;
import com.telecom.deviceservice.model.Device;
import com.telecom.deviceservice.model.DeviceStatus;
import com.telecom.deviceservice.model.DeviceType;
import com.telecom.deviceservice.repository.DeviceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DeviceService {

    private final DeviceRepository deviceRepository;

    @Transactional(readOnly = true)
    public List<Device> getAllDevices() {
        return deviceRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Device getDeviceById(Long id) {
        return deviceRepository.findById(id)
                .orElseThrow(() -> new DeviceNotFoundException("Device not found with id: " + id));
    }

    @Transactional(readOnly = true)
    public Device getDeviceBySerialNumber(String serialNumber) {
        return deviceRepository.findBySerialNumber(serialNumber)
                .orElseThrow(() -> new DeviceNotFoundException("Device not found with serial number: " + serialNumber));
    }

    @Transactional
    public Device createDevice(Device device) {
        return deviceRepository.save(device);
    }

    @Transactional
    public Device updateDevice(Long id, Device deviceDetails) {
        Device device = getDeviceById(id);
        
        device.setName(deviceDetails.getName());
        device.setType(deviceDetails.getType());
        device.setModel(deviceDetails.getModel());
        device.setManufacturer(deviceDetails.getManufacturer());
        device.setFirmwareVersion(deviceDetails.getFirmwareVersion());
        device.setIpAddress(deviceDetails.getIpAddress());
        device.setStatus(deviceDetails.getStatus());
        device.setLocation(deviceDetails.getLocation());
        
        return deviceRepository.save(device);
    }

    @Transactional
    public void deleteDevice(Long id) {
        Device device = getDeviceById(id);
        deviceRepository.delete(device);
    }

    @Transactional
    public Device updateDeviceStatus(Long id, DeviceStatus status) {
        Device device = getDeviceById(id);
        device.setStatus(status);
        return deviceRepository.save(device);
    }

    @Transactional(readOnly = true)
    public List<Device> getDevicesByType(DeviceType type) {
        return deviceRepository.findByType(type);
    }

    @Transactional(readOnly = true)
    public List<Device> getDevicesByStatus(DeviceStatus status) {
        return deviceRepository.findByStatus(status);
    }

    @Transactional(readOnly = true)
    public List<Device> getDevicesNeedingMaintenance() {
        return deviceRepository.findDevicesNeedingMaintenance();
    }

    @Transactional(readOnly = true)
    public Map<DeviceStatus, Long> getDeviceStatusSummary() {
        Map<DeviceStatus, Long> statusSummary = new HashMap<>();
        
        for (DeviceStatus status : DeviceStatus.values()) {
            statusSummary.put(status, 0L);
        }
        
        deviceRepository.findAll().forEach(device -> {
            DeviceStatus status = device.getStatus();
            statusSummary.put(status, statusSummary.get(status) + 1);
        });
        
        return statusSummary;
    }
}