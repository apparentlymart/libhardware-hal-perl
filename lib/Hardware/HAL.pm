
package Hardware::HAL;

use strict;
use warnings;
use Net::DBus;
use Hardware::HAL::Device;

my $manager = undef;
my $hal = undef;

sub manager {
    my ($class) = @_;

    unless ($manager) {
        my $bus = Net::DBus->system;
        $hal = $bus->get_service("org.freedesktop.Hal");
        $manager = $hal->get_object("/org/freedesktop/Hal/Manager", "org.freedesktop.Hal.Manager");
    }

    return $manager;
}

sub hal {
    my ($class) = @_;

    $class->manager; # Just to force $hal to be loaded
    return $hal;
}

sub computer {
    my ($class) = @_;

    return $class->device_by_udi("/org/freedesktop/Hal/devices/computer");
}

sub all_devices {
    my ($class) = @_;

    return $class->_wrap_devices($class->manager->GetAllDevices());
}

sub devices_with_capability {
    my ($class, $capability) = @_;

    return $class->_wrap_devices($class->manager->FindDeviceByCapability($capability));
}

sub devices_with_property_value {
    my ($class, $property, $value) = @_;

    return $class->_wrap_devices($class->manager->FindDeviceStringMatch($property, $value));
}

sub devices_by_subsystem {
    my ($class, $subsystem) = @_;

    return $class->devices_with_property_value("info.subsystem", $subsystem);
}

sub device_by_udi {
    my ($class, $udi) = @_;

    my $dbus_object = $class->hal->get_object($udi, "org.freedesktop.Hal.Device");

    return $dbus_object ? Hardware::HAL::Device->from_dbus_object($dbus_object) : undef;
}

sub _wrap_devices {
    my ($class, $dbus_devices) = @_;

    local $_;
    return map {
        my $udi = $_;
        my $dbus_object = $class->hal->get_object($udi, "org.freedesktop.Hal.Device");
        Hardware::HAL::Device->from_dbus_object($dbus_object);
    } @$dbus_devices;
}

1;

=head1 NAME

Hardware::HAL - Perl API for freedesktop.org Hardware Abstraction Layer

=head1 SYNOPSIS

    my @devices = Hardware::HAL->all_devices();
    foreach my $device (@devices) {
        print $device->product_name, "\n";
    }

=head1 DESCRIPTION

This is a wrapper around the HAL DBus API that makes it a little more
Perly. Only the methods for retrieving device information are directly
implemented; the methods for manipulating devices are not exposed here.

=head1 METHODS

=head2 Hardware::HAL->computer

Returns a device object representing the computer on which HAL is running.

=head2 Hardware::HAL->device_by_udi($udi)

Given a device UDI, returns that device or undef if the device does not exist.

=head2 Hardware::HAL->all_devices

Returns a list of all devices that HAL knows about.

=head2 Hardware::HAL->devices_with_capability($capability)

Returns a list of all devices that have the given HAL capability.

=head2 Hardware::HAL->devices_by_subsystem($subsystem)

Returns a list of all devices that belong to the given HAL subsystem.

=head2 Hardware::HAL->devices_with_property_value($property, $value)

Returns a list of all devices which have the given property with the given value. C<$value> must be a string.

=head1 AUTHOR

Copyright 2008 Martin Atkins <mart@degeneration.co.uk>

=head1 LICENCE

This module may be distributed under the same terms as Perl itself.

