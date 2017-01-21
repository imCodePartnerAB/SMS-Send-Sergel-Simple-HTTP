package SMS::Send::Sergel::Simple::HTTP;

use HTTP::Tiny;
use URI::Escape;
use base 'SMS::Send::Driver';
use strict;
use warnings;
our $VERSION = '0.01';

sub new {
  my ($class, %args) = @_;

  unless (
    $args{'_login'}
    && $args{'_password'}
    && $args{'_sender'}
    && $args{'_serviceid'}
  ) {
    die "$class needs hash with _serviceid, _login, _password and _sender.\n"
  }

  my $self = bless {%args}, $class;
  $self->{base_url} = $args{_url} // 'https://ws1.sp247.net/smscsimplehttp';
  return $self;
}

sub send_sms {
  my ($self, %args) = @_;
  my $query = $self->{base_url}
              . '?ServiceId='   . $self->{_serviceid}
              . '&Username='    . $self->{_login}
              . '&Password='    . $self->{_password}
              . '&Destination=' . uri_escape($args{'to'})
              . '&Source='      . uri_escape($self->{_sender})
              . '&Userdata='    . uri_escape($args{'text'});

  my $response = HTTP::Tiny->new->get($query);

  if ($self->{_debug}) {
    return $response;
  }

  if ($response->{success}) {
    my ($resultCode, $resultDescription, $messageId) = split /;/, $response->{content};
    my $OK_codes = {
      1000 => 'Sent',
      1001 => 'Delivered',
      1005 => 'Queued',
    };

    if (exists($OK_codes->{$resultCode})) {
      return 1;
    } else {
      return 0;
    }
  } else {
   return 0;
  }
}

1;

__END__

=encoding utf-8

=head1 NAME

SMS::Send::Sergel::Simple::HTTP

=head1 SYNOPSIS

  use SMS::Send;
  use SMS::Send::Sergel::Simple::HTTP;

  # Create sender
  my $sender = SMS::Send->new('Sergel::Simple::HTTP',
    _url       => 'API url'
    _serviceid => 'serviceid',
    _login     => 'username',
    _password  => 'password',
    _sender    => 'SENDER' # Text or phone number
  );

  # Send message, returns true if OK
  my $sent = $sender->send_sms(
    text => 'My message text',
    to => '+4612345678', # Phone number
  );

  if ($sent) {
    # OK
  } else {
    # Not OK
  }


=head1 DESCRIPTION

SMS::Send::Sergel::Simple::HTTP is a perl library for
sending SMS with the Sergel Simple HTTP SMS service.

=head1 AUTHOR

Eivin Giske Skaaren E<lt>eivin@sysmystic.comE<gt>

=head1 COPYRIGHT

Copyright 2017- Eivin Giske Skaaren

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
