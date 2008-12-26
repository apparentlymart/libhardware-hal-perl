
package Hardware::HAL::Device;

use strict;
use warnings;
use Hardware::HAL;

sub from_dbus_object {
    my ($class, $object) = @_;

    die "Argument $object is not a DBus object" unless UNIVERSAL::isa($object, 'Net::DBus::RemoteObject');

    return bless { object => $object }, $class;
}

sub dbus_object {
    return $_[0]->{object};
}

sub property_value {
    my ($self, $property) = @_;

    return $self->dbus_object->GetProperty($property);
}

sub has_capability {
    my ($self, $capability) = @_;

    return $self->dbus_object->QueryCapability($capability) ? 1 : 0;
}

sub has_property {
    my ($self, $property) = @_;

    return $self->dbus_object->PropertyExists($property) ? 1 : 0;
}

sub product_name {
    return eval { $_[0]->property_value("info.product") } || undef;
}

sub vendor_name {
    return eval { $_[0]->property_value("info.vendor") } || undef;
}

sub udi {
    return $_[0]->property_value("info.udi");
}

sub category {
    return eval { $_[0]->property_value("info.category") } || undef;
}

sub capabilities {
    my ($self) = @_;
    my $capabilities = $self->property_value("info.capabilities");
    return $capabilities ? @$capabilities : ();
}

sub parent_device {
    my ($self) = @_;
    my $parent_udi = $self->property_value("info.parent");

    return $parent_udi ? Hardware::HAL->device_by_udi($parent_udi) : undef;
}

sub child_devices {
    my ($self) = @_;

    return Hardware::HAL->devices_with_property_value("info.parent", $self->udi);
}

1;

=head1 NAME

Hardware::HAL::Device - Represents a device from HAL

=head1 DESCRIPTION

Instances of this class represent specific devices from HAL on
a particular system.

Instances can be obtained via the class methods of L<Hardware::HAL>.

=head1 METHODS

=head2 $self->udi

Returns the UDI of the device.

=head2 $self->category

Returns the category of the device.

=head2 $self->product_name

Returns a human-readable name for the device.

=head2 $self->vendor_name

Returns a human-readable name for the vendor of the device.

=head2 $self->property_value($property)

Returns the value of the given property.

=head2 $self->has_property($property)

Returns 1 if the device has the given property, or 0 otherwise.

=head2 $self->has_capability($capability)

Returns 1 if the device has the given capability, or 0 otherwise.

=head2 $self->capabilities

Returns a list of all of the device's capabilities.

=head2 $self->parent_device

Returns an object representing the device's parent device, or C<undef> if it has no parent.

=head2 $self->child_devices

Returns a list of devices that have this device as their parent.

=head2 $self->dbus_object

Returns the DBus object that underlies this instance. This is an instance of L<Net::DBus::RemoteObject>.

