{ ... }:
{
  services.hyprsunset = {
    enable = true;
    settings = {
      profile = [
        {
          time = "6:30";
          identity = true;
        }
        {
          time = "21:00";
          temperature = 3500;
        }
      ];
    };
  };
}
